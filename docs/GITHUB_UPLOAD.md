# Upload to GitHub (Windows / GitHub Desktop)

Do **not** upload this repository ZIP as a single file to GitHub: reviewers
must be able to browse the source and CSV/MAT records separately.

1. Unzip `ISAS2026_GITHUB_CODE_DATA_CC_BY_4_0_v4.zip`. The extracted folder
   should contain `README.md`, `.gitignore`, `CITATION.cff`, `code/`,
   `data/`, `docs/` and `scripts/` directly. There should be no
   `manuscript/` directory.
2. Open [GitHub Desktop](https://desktop.github.com/) and sign in.
3. File > Add local repository > Choose the extracted folder. If GitHub
   Desktop offers **create a repository here**, use that option.
4. Confirm that changes to `code/results/` and other generated output
   folders are excluded by `.gitignore`. The archived `data/` files should
   be included in the commit.
5. Make the initial commit, choose **Publish repository**, and check
   **Keep this code private** is **unchecked** only after the release
   checklist and file-ownership/licensing review are complete.
6. Open the GitHub URL in an incognito window. The directory structure,
   CSV/MAT files and runnable source files must be publicly visible;
   paper manuscripts and response letters are intentionally absent.
7. After running a clean reproduction and approving the software license, create a
   versioned Release. Only then consider a Zenodo DOI for that release.

File count is greater than the normal GitHub web upload batch limit, so
GitHub Desktop (or the Git command line) is recommended. No repository
has been created or published by this file-cleanup process.
