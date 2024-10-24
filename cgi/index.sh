#!/bin/bash

# constants declared here
PROJECT_DIR=$(cd "$(dirname "$0")" && cd ".." && pwd) # $0 is a special variable that contains the path to the current script; using cd is a trick to resolve symlinks
STUDENT_LIST_FILE="${PROJECT_DIR}/static/student.list"
PROJECT_TMP_DIR="${PROJECT_DIR}/tmp"
BUILD_STUDENT_SH="${PROJECT_DIR}/cgi/build.student.sh"

# some other setup; reading templates etc
pageHtml=$(cat "${PROJECT_DIR}/static/page.template.html" )

# students that finished this assignment are good students
goodStudents=() # initializing arrays
naughtystudents=()

# create "tmp" if it's missing
[[ -d "$PROJECT_TMP_DIR" ]] || mkdir -p "$PROJECT_TMP_DIR"

# Separating student.list table into full names (some students have middle names) and emails
awk '{for (i=1; i < NF; i++) printf "%s ", $i; print "\t"$NF}' "$STUDENT_LIST_FILE" > "${PROJECT_TMP_DIR}/split.student.list"

# building student lists
while IFS=$'\t' read -r name email; do #added "" and ; do
  lcName=${name,,}
    # taking only the 1st matching file; 2>/dev/null supresses error messages
  actualImgFName=$(find "${PROJECT_DIR}/student.images/" -type f -name "${lcName// /.}"'*' 2>/dev/null | head -n 1)
  if (( ${#actualImgFName} > 0 )); then # checking if a file exists
    if file -b --mime "${actualImgFName}" | grep -q "^image/"; then # and is an image
      # good student detected
       goodStudents=("$(source "$BUILD_STUDENT_SH"  "${name}" "${email}" "/student.images/$(basename "${actualImgFName}")" )")
    fi
  else
    # naughty student detected
    naughtystudents+=("$(source "$BUILD_STUDENT_SH" "${name}" "${email}" )")
  fi
done < "${PROJECT_TMP_DIR}/split.student.list"

#joining html pieces together
goodStr=""
for student in "${goodStudents[@]}"; do
  goodStr+="${student}" #new line
done
naughtyStr=""
for student in "${naughtystudents[@]}"; do
  naughtyStr+="${student}"
done

finalHtml="${pageHtml//<!--goodStudentsHtml-->/$goodStr}"
finalHtml="${finalHtml//<!--naughtyStudentsHtml-->/$naughtyStr}"



# outputting html for Apache to send and browser to render
echo "Content-Type: text/html"
echo

echo "$finalHtml"

