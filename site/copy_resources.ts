// Runs before each render of the website (Quarto runs .ts files with its
// built-in Deno, so no R or Python is needed). Copies the case-study data and
// the data package from data/ into the site, so readers can download them and
// the playground can load them. The originals stay in data/.

const repo = "..";

function copy(from: string, to: string) {
  Deno.copyFileSync(from, to);
}

// Playground pages read the data from their own folder, exactly as the
// downloadable chapter projects do: read.csv("students.csv")
for (const file of ["students.csv", "semesters.csv"]) {
  copy(`${repo}/data/${file}`, `playground/${file}`);
}

// Downloads: the data package and every data file
Deno.mkdirSync("downloads", { recursive: true });
for (const entry of Deno.readDirSync(`${repo}/data`)) {
  if (!entry.isFile) continue;
  if (/\.(csv|xlsx|sav|tar\.gz)$/.test(entry.name)) {
    copy(`${repo}/data/${entry.name}`, `downloads/${entry.name}`);
  }
}
