// Playground: runs R exercises in the reader's browser with webR.
//
// A page declares its exercises like this:
//
//   <div class="r-exercise">
//     <p>Instructions ...</p>
//     <script type="text/x-r" data-role="starter"> starter code </script>
//     <script type="text/x-r" data-role="solution"> solution code </script>
//   </div>
//
// and the data files to load with a container element:
//
//   <div id="playground" data-base="/R4NTR/data/" data-files="students.csv semesters.csv"></div>
//
// Each exercise becomes an editor with Run, Reset, and Show solution buttons.
// The data files are copied into R's working directory, so code can use
// read.csv("students.csv") exactly as in RStudio.

import { WebR } from "https://webr.r-wasm.org/v0.5.4/webr.mjs";

const container = document.getElementById("playground");
const status = document.getElementById("playground-status");
const exercises = [...document.querySelectorAll(".r-exercise")];

function setStatus(text, state) {
  if (!status) return;
  status.textContent = text;
  status.dataset.state = state;
}

function codeOf(exercise, role) {
  const node = exercise.querySelector(`script[data-role="${role}"]`);
  return node ? node.textContent.replace(/^\n/, "").replace(/\s+$/, "") : "";
}

function button(label, className) {
  const b = document.createElement("button");
  b.type = "button";
  b.textContent = label;
  b.className = className;
  return b;
}

// Build the editor for each exercise straight away, so readers can read and
// type while R is still loading.
const editors = exercises.map((exercise) => {
  const starter = codeOf(exercise, "starter");
  const solution = codeOf(exercise, "solution");

  const editor = document.createElement("textarea");
  editor.className = "r-editor";
  editor.spellcheck = false;
  editor.value = starter;
  editor.rows = Math.max(4, starter.split("\n").length + 1);
  editor.setAttribute("aria-label", "R code");

  // Tab inserts two spaces instead of leaving the editor
  editor.addEventListener("keydown", (e) => {
    if (e.key === "Tab" && !e.shiftKey) {
      e.preventDefault();
      const { selectionStart: s, selectionEnd: t, value } = editor;
      editor.value = value.slice(0, s) + "  " + value.slice(t);
      editor.selectionStart = editor.selectionEnd = s + 2;
    }
    if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      run.click();
    }
  });

  const bar = document.createElement("div");
  bar.className = "r-toolbar";
  const run = button("Run", "r-run");
  run.disabled = true;
  const reset = button("Reset", "r-reset");
  const show = button("Show solution", "r-show");
  bar.append(run, reset);
  if (solution) bar.append(show);

  const output = document.createElement("div");
  output.className = "r-output";
  output.setAttribute("aria-live", "polite");

  const solutionBox = document.createElement("pre");
  solutionBox.className = "r-solution";
  solutionBox.hidden = true;
  solutionBox.textContent = solution;

  reset.addEventListener("click", () => {
    editor.value = starter;
    output.replaceChildren();
  });
  show.addEventListener("click", () => {
    solutionBox.hidden = !solutionBox.hidden;
    show.textContent = solutionBox.hidden ? "Show solution" : "Hide solution";
  });

  exercise.append(editor, bar, output, solutionBox);
  return { editor, run, output };
});

async function main() {
  setStatus("Starting R in your browser. The first time can take 10 to 30 seconds.", "loading");

  const webR = new WebR();
  await webR.init();

  // Copy the case-study data into R's working directory
  const base = container?.dataset.base ?? "";
  const files = (container?.dataset.files ?? "").split(/\s+/).filter(Boolean);
  for (const file of files) {
    const response = await fetch(base + file);
    if (!response.ok) throw new Error(`Could not load ${file} (${response.status})`);
    const bytes = new Uint8Array(await response.arrayBuffer());
    await webR.FS.writeFile(`/home/web_user/${file}`, bytes);
  }

  setStatus("R is ready. Edit the code and press Run (or Ctrl+Enter).", "ready");

  const shelter = await new webR.Shelter();

  for (const { editor, run, output } of editors) {
    run.disabled = false;
    run.addEventListener("click", async () => {
      run.disabled = true;
      output.replaceChildren();
      try {
        const result = await shelter.captureR(editor.value, {
          withAutoprint: true,
          captureStreams: true,
          captureConditions: false,
          captureGraphics: { width: 640, height: 400 },
        });
        const text = result.output
          .filter((line) => line.type === "stdout" || line.type === "stderr")
          .map((line) => line.data)
          .join("\n");
        if (text) {
          const pre = document.createElement("pre");
          pre.textContent = text;
          output.append(pre);
        }
        for (const image of result.images ?? []) {
          const canvas = document.createElement("canvas");
          canvas.width = image.width;
          canvas.height = image.height;
          canvas.getContext("2d").drawImage(image, 0, 0);
          output.append(canvas);
        }
        if (!text && !(result.images ?? []).length) {
          const note = document.createElement("p");
          note.className = "r-note";
          note.textContent = "Done (the code ran but printed nothing).";
          output.append(note);
        }
      } catch (error) {
        const pre = document.createElement("pre");
        pre.className = "r-error";
        pre.textContent = String(error.message ?? error).replace(/^Error: /, "Error: ");
        output.append(pre);
      } finally {
        await shelter.purge();
        run.disabled = false;
      }
    });
  }
}

main().catch((error) => {
  console.error(error);
  setStatus(
    "R could not start in this browser. You can still download the chapter project below and run the exercises in RStudio.",
    "error"
  );
});
