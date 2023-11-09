#!/bin/bash

# - Ensuring that the content type header is sent before any HTML content is included in the response
echo "Content-Type: text/html"
echo

# constants declared here
PROJECT_DIR=$(cd "$(dirname "$0")" && cd ".." && pwd) # $0 is a special variable that contains the path to the current script; using cd is a trick to resolve symlinks
STUDENT_LIST_FILE="${PROJECT_DIR}/static/student.list"
PROJECT_TMP_DIR="${PROJECT_DIR}/tmp"
BUILD_STUDENT_SH="${PROJECT_DIR}/cgi/build.student.sh"

# some other setup; reading templates etc
pageHtml=$(cat "${PROJECT_DIR}/static/page.template.html")

# students that finished this assignment are good students
goodStudents=() # initializing arrays
naughtyStudents=()

# Separating student.list table into full names (some students have middle names) and emails
# - Create folder 'split.student.list' in 'tmp' folder if it doesn't exist through awk, had to give +w permissions to 'tmp'
awk '{for (i=1; i < NF; i++) printf "%s ", $i; print "\t"$NF}' "$STUDENT_LIST_FILE" > "${PROJECT_TMP_DIR}/split.student.list"

# building student lists
while IFS=$'\t' read -r name email; do
  lcName=${name,,}
    # taking only the 1st matching file; 2>/dev/null supresses error messages
    # - Looks for images that has filenames of students where spaces has been replaced with '.'
  actualImgFName=$(find "${PROJECT_DIR}/student.images/" -type f -name "${lcName// /.}"'*' 2>/dev/null | head -n 1)
  if (( ${#actualImgFName} > 0 )); then # checking if a file exists
    if file -b --mime "${actualImgFName}" | grep -q "^image/"; then # and is an image
      # good student detected
       goodStudents+=("$(source "$BUILD_STUDENT_SH" "${name}" "${email}" "/student.images/$(basename "${actualImgFName}")" )")
    fi
  else
    # naughty student detected
    naughtyStudents+=("$(source "$BUILD_STUDENT_SH" "${name}" "${email}" )")
  fi
done < "${PROJECT_TMP_DIR}/split.student.list"

#joining html pieces together
# - Added '+=' after 'naughtStr' to append and sort each listing within the array
goodStr=""
for student in "${goodStudents[@]}"; do
  goodStr+="${student}"
done
naughtyStr=""
for student in "${naughtyStudents[@]}"; do
  naughtyStr+="${student}"
done

finalHtml="${pageHtml//<!--goodStudentsHtml-->/$goodStr}"
finalHtml="${finalHtml//<!--naughtyStudentsHtml-->/$naughtyStr}"

# outputting html for Apache to send and browser to render
echo "$finalHtml"