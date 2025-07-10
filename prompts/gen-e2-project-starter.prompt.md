# Gen-e2 Project Starter Prompt

We will start a new Gen-e2 projec : :

1. create the following .MD files with the names in bold bellow
2. add as status information filed at the end of the naming of each file created whith :
   
   * " [?][last comit timestamp]" when file still need some reponses
   
   * " [OK][last comit timestamp]" when all reponses have been provided
   
So team will now witch file need to be completed and when it has been updated.
Team can ask you to list them the unanswerd questions or responses to be updated, so you can update the status of each files.

You have to create the structure project tree as described bellow with the timestamp status added the each file name created and update it everytime the file is comited.

## Files & Questions to create

1. **Project Requirements and Features**:
   - What are the project requirements and features?
   - Are there any specific requirements for the project, like compliance, security, etc.?

2. **Infrastructure**:
   - Which cloud will we be using?
   - What is our target architecture?
   - Do you want to create the infrastructure files, and in which format (e.g., Terraform, CloudFormation)?

3. **Legacy App**:
   - Is this a legacy app replatforming? (If yes, create a LegacyApp folder)

4. **Project Type**:
   - Will this be an API-first project or a front-end first project?
   - Are there any requirements for the API, like being RESTful, GraphQL, etc.?
   - Is there any need for specific languages or frameworks?

## Automated Markdown Status Tracking

Automatically generate a script `scripts/update_status.sh` that:
  - Scans all `.md` files in the project (including subfolders, except `README.md` and `TODO.md`).
  - Updates their filename with the status ([?] or [OK]) and the last commit date.
Automatically install a Git `post-commit` hook in `.git/hooks/post-commit` that runs this script after each commit.
Make these scripts executable (`chmod +x scripts/update_status.sh .git/hooks/post-commit`).

**Example script to generate:**
```bash
#!/bin/bash
# Updates status and date in the name of all .md files in the project

set -e

FILES=()
while IFS= read -r -d '' f; do
  fname=$(basename "$f")
  case "$fname" in
    "README.md"|"TODO.md") continue;;
  esac
  relpath="${f%.md}"
  base=$(echo "$relpath" | sed -E 's/ ([\?OK]+)\[[0-9\-]+\]$//')
  FILES+=("$base")
done < <(find . -type f -name '*.md' -print0)

get_status() {
  local file="$1"
  if grep -E -q "\?\s*$|TODO|À compléter|\[\s*\]" "$file"; then
    echo "[?]"
  else
    echo "[OK]"
  fi
}

for base in "${FILES[@]}"; do
  file=$(ls "${base}"*.md 2>/dev/null | head -n1)
  [ -z "$file" ] && continue
  status=$(get_status "$file")
  last_commit=$(git log -1 --format="%cd" --date=short -- "$file" 2>/dev/null)
  [ -z "$last_commit" ] && last_commit="$(date +%Y-%m-%d)"
  newname="${base} ${status}[${last_commit}].md"
  if [[ "$file" != "$newname" ]]; then
    mv "$file" "$newname"
    echo "Renamed: $file -> $newname"
  fi
done
```

**Example post-commit hook to generate:**
```bash
#!/bin/sh
bash scripts/update_status.sh
```

---

## Actions Based on Answers

1. **Update Project Structure**:
    Here is the base project structure:

    ```plaintext
    .
    ├── README.md -- Describe the project and project goals
    ├── scripts/ -- Contains scripts to manage the project
    │   ├── manage.sh -- Manages servers and services (start,stop,status)
    │   ├── setup.sh -- Installs project dependencies
    │   ├── init_db.sh -- Initializes the database (if required)
    ├── apps/ -- Contains the front-end application
    │   ├── mobile/ -- Contains the mobile application
    │   └── web/ -- Contains the web application
    ├── docs/ -- Contains project documentation
    │   ├── features/ -- Contains documentation for project features (one file per feature)
    │   ├── project-overview/ -- Contains an overview of the project
    │   ├── meeting-transcripts/ -- Contains transcripts of project meetings & Mob Programming sessions
    │   ├── index.md -- Main documentation file, indexing all other documentation
    │   └── CONTRIBUTE.md -- Describes the project structure and best practices for contributions
    ├── back-end/ -- Contains the back-end application
    │   ├── api/ -- Contains the API code
    │   ├── services/ -- Contains the services code
    │   ├── data/ -- Contains the data access code (e.g., database, SQL, ORM, etc.)
    │   └── docs/ -- Contains back-end documentation
    ├── infra/ -- Contains infrastructure code
    │   ├── modules/ -- Contains Terraform modules
    │   ├── tf-components/
    │   └── docs/
    │       └── feature/
    │           └── authentication/
    ├── DevOps/
    │   ├── pipeline/
    |   └── docs/
    └── services/ -- Contains serverless functions
        └── functions/ -- Contains the serverless functions
    ```

    - Update the project structure based on the answers.
    - Update the README.md file, docs/index.md file, and `infra/docs/feature/authentication/index.md` file with the information gathered.

2. **Create TODO.md**:
   - Create the `TODO.md` file and split it in a way that makes sense for this project.
   - Format:

     ```markdown
     ## Domain
     [ ] Task to be done (owner)
     ```

   - Add tasks for each area of the project, like front-end, back-end, infra, etc.
   - Ensure tasks are detailed and small enough to be done in a few hours.
   - Include tasks outside of development, like DevOps tasks, security tasks, etc.
   - Add lines regarding reviewing all generated files (like Architecture or API doc) and updating them as needed.

3. **Documentation**:
   - If the project is API-First or has an API, suggest a swagger file `back-end/docs/apidoc.yaml` .
   - Suggest an infrastructure architecture diagram (in PLANTUML) and add it into `infra/docs` folder.
   - In the `docs/features/` folder, create a file for each feature that will be developed in this project.

4. **Tools and Dependencies**:
   - Suggest tools that could be useful for this project, like a specific database, a specific CI/CD tool, etc.
   - Create all necessary files for the project, like the .gitignore, the .gitattributes, etc.
   - Depending on the selected language, create the necessary files for it (like a package.json for a Node.js project or requirements.txt for python).
   - If a virtual environment is needed, suggest it and create it. Load all dependencies needed for the project.

5. **Infrastructure Files**:
   - Based on the user's preference, create the necessary infrastructure files (e.g., Terraform, CloudFormation) in the `infra/` directory.

6. **Version Control**:
   - Ensure to initialize a Git repository and create an initial commit.

7. **CI/CD Pipeline**:
   - Set up a CI/CD pipeline using a service like GitHub Actions, GitLab CI, or Jenkins.
   - Create the pipeline details in the `DevOps/pipeline` folder
   - Create a documentation of the application pipeline in the `DevOps/docs` folder.

8. **Testing**:
   - Set up testing frameworks and write initial test cases.

9. **Environment Configuration**:
   - Provide guidelines for handling environment variables and secrets (e.g., using .env files).

10. **Code Quality**:

    - Suggest tools for code quality checks, such as linters and formatters.

11. **Security**:
    - Include a section on security best practices and tools for vulnerability scanning.

12. **Deployment**:
    - Provide guidelines for deployment, including staging and production environments.

## Final Steps

1. **Project Name**:
   - Suggest a project name and ask if it's ok to create the project. If the user agrees, create the project with the name suggested.

2. **Review**:
   - Once all the other files are created, and you're clear on the requirements, review the gitignore files, as you might want to add more (like venv or node_modules).

3. **Check File Creation**:
   - Ensure that all the necessary files and folders have been created as per the project structure.

4. **Deploy Requirements**:
   - Run the necessary commands to deploy all the dependencies listed in the requirements files (e.g., `npm install` for Node.js, `pip install -r requirements.txt` for Python).

<!-- Prompt version 0.4 -->
