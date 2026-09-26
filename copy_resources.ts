// Runs before each render of the website (Quarto runs .ts files with its
// built-in Deno, so no R or Python is needed). Copies the case-study data and
// the data package from data/ into the site, so readers can download them and
// the playground can load them. The originals stay in data/.

const repo = ".";

function copy(from: string, to: string) {
  Deno.copyFileSync(from, to);
}

// Playground pages read the data from their own folder, exactly as the
// downloadable chapter projects do: read.csv("students.csv")
Deno.mkdirSync("content/playground", { recursive: true });
for (const file of ["students.csv", "semesters.csv", "questionnaire.csv", "supervisors.csv",
                     "counselling_visits.csv", "open_responses.csv", "open_responses_coded.csv"]) {
  copy(`${repo}/data/${file}`, `content/playground/${file}`);
}
// The language model's saved coding (Chapter 18) is made by data-raw/run_ai_coding.R
copy(`${repo}/data-raw/ai_coding_results.csv`, "content/playground/ai_coding_results.csv");

// Downloads: the data package and every data file
Deno.mkdirSync("downloads", { recursive: true });
for (const entry of Deno.readDirSync(`${repo}/data`)) {
  if (!entry.isFile) continue;
  if (/\.(csv|xlsx|sav|tar\.gz)$/.test(entry.name)) {
    copy(`${repo}/data/${entry.name}`, `downloads/${entry.name}`);
  }
}
