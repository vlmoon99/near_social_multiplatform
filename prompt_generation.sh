#!/usr/bin/env bash

# ============================
# CONFIGURATION
# ============================
OUTPUT_FILE="prompt.txt"

# File extensions to INCLUDE (add any file types you want to collect)
INCLUDED_EXTENSIONS=(
  "dart"
  "sql"
  "txt"
  "yaml"
  "json"
  "md"
  "xml"
  "html"
  "css"
  "js"
)

# Folders to scan recursively
FOLDERS=(
  "lib/utils/"
)

# Individual files to include explicitly
FILES=(
  "lib/main.dart"
)

# File extensions to EXCLUDE (generated files, etc.)
EXCLUDED_EXTENSIONS=(
  "g.dart"
)

# ============================
# LLM INSTRUCTIONS (HARDCODED)
# ============================
read -r -d '' LLM_PROMPT << 'EOF'
Rules of writing code:
1. Ensure that the 'Legacy' colors and textstyles are strictly avoided in new widgets.
2. Do not change anything in app_theme file
3. Return the full code for the modified files only in the formatted dart way with 1 click copy paste mode in google ai studio I must to have this copy button.
4. Dont use any hardcoded, use strictly text and colors from localization and colors and text styles, only in the situation when u stuck - u can use hardcode
5. Make sure u are using the same way of creating sizes of the widgets and make my ui responsive, but at the same time semi adapted(because on the laptops and tablets right now I see the mobile version)
6. Make sure u dont write any comments inside code
7. Dont use private values (variables,functions,classes with underscore like this one -> _value; _function(), _BlocStateClass), all parts of the code must be public.

Main logic of Evolut app :
1.User can login with email and phone
2.User can create his profile and this profile must be sync with the server, the latest data update is priority between devices.
3.User can have create LifeSpehres and insdie LifeSpheres he can create LifeSphersActivity (by the very simialr rules and UI as with LifeSpheres).
4.Each LifeSphersActivity has : 1.day of the task (some day of the week from 1 to 7), 2.time to execute (how much time user will spend on this task).
5.Each LifeSphersActivity will be converted in the ExecutedTask insdie user Calendar , and each ExecutedTask can have the real time executed (becuase user can plan 30min , but execute 10min, so it's 30% of his planned execution), and mark (done or not done)
6.After all this lan creation with  LifeSpheres and LifeSphersActivity, we mark our tasks (ExecutedTask) on the calendar , and after that we can see the analysis. In the app we will have a few types of analysis which user can see localy on his devices(it's becuase we are gonna enrypt his data on hte server and only his device can calculate his analytics) :
  - First type of analysis is a Calendar on which he can see a next diaposons of the time : day,week,month,year , in case of the day he can see each life sphere corelation with planned life spheres and real execution from the planned in %.(If he will tap on the life sphere he will see the similar info but for each LifeSphersActivity the same % corelations).
    On the week, month, year Calendar menu he will see the days like in the std mobiel app calendar mode with each day circled in the colorful border , which will show the corelation betwee planned/executed in %.(He will also have an option to filter it by LifeSpheres and LifeSphersActivity).
  - Second type of analysis is a Graph on which he can see a next diaposons of the time : week,month,year,all, all this screens will ahve teh similar ui and it will shwo the chart of total points earned, each task from planned can give u some amount of points, and this chart will no have any downside, if u do nothing - the chart will stay on one place or horizontal,
    if u perform some task - u can earn some amount of the points on the chart. So each time u will execute some task this chart will grow a little bit. Also there will be filters by LifeSpheres/LifeSphersActivity , by which user can filtred his tasks and see his progress on the bar in according to the corresponding filters.


Instructions:
1.Read and Analyze ALL Context Code
2.Make sure the DoItChart is the same size as PlannedLifeChart, becuase right now DoItChart looks smaller than PlannedLifeChart also
DoItChart must be optimized in order to not go outise my background icon photo, I dont wanna see out of circle colors at all
3.I wanna to make DoITTaskItem more area to tpa in order to done/undone, right now it's only a little cirle, I anna maek more sapce (excpetd the plcae wher icon of ediitng is located, it must the open the same modal as right now, but also the biggest are of opening the editing modal will be better).
4.Make sure that in inner done it screen on week date frame i will have the day spitter as on inner planned page with planned activities but on do it screen it must be for done it activities, also just synchronize them with planned activities page, make sure they are synchronized at 1 to 1 what i can see on planned side as well on done it side

EOF

# ============================
# INTERNAL HELPERS
# ============================

# Check if a file should be excluded based on its extension pattern
should_exclude_file() {
  local file="$1"
  local filename=$(basename "$file")
  
  for excluded_ext in "${EXCLUDED_EXTENSIONS[@]}"; do
    if [[ "$filename" == *".$excluded_ext" ]]; then
      return 0
    fi
  done
  
  return 1
}

# Check if a file has an included extension
has_included_extension() {
  local file="$1"
  local filename=$(basename "$file")
  
  for included_ext in "${INCLUDED_EXTENSIONS[@]}"; do
    if [[ "$filename" == *".$included_ext" ]]; then
      return 0
    fi
  done
  
  return 1
}

write_file() {
  local file="$1"
  
  if should_exclude_file "$file"; then
    echo "⏭️  Skipping generated file: $file"
    return
  fi
  
  if ! has_included_extension "$file"; then
    return
  fi
  
  echo "========================================" >> "$OUTPUT_FILE"
  echo "FILE: $file" >> "$OUTPUT_FILE"
  echo "========================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  echo -e "\n\n" >> "$OUTPUT_FILE"
}

# ============================
# SCRIPT LOGIC
# ============================

# 1. Clear/Create the output file
> "$OUTPUT_FILE"

echo "📦 Collecting files with extensions: ${INCLUDED_EXTENSIONS[*]}"
echo "🚫 Excluding files with extensions: ${EXCLUDED_EXTENSIONS[*]}"
echo ""

# 2. Collect from folders
for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    echo "📂 Scanning folder: $folder"
    find "$folder" -type f | sort | while read -r file; do
      write_file "$file"
    done
  else
    echo "⚠️  Folder not found: $folder"
    echo "⚠️ Folder not found: $folder" >> "$OUTPUT_FILE"
  fi
done

echo ""

# 3. Collect individual files
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "📄 Adding file: $file"
    write_file "$file"
  else
    echo "⚠️  File not found: $file"
    echo "⚠️ File not found: $file" >> "$OUTPUT_FILE"
  fi
done

# 4. Append LLM Instructions
if [ -n "$LLM_PROMPT" ]; then
  echo ""
  echo "📝 Appending LLM Instructions..."
  echo "" >> "$OUTPUT_FILE"
  echo "################################################################################" >> "$OUTPUT_FILE"
  echo "# #" >> "$OUTPUT_FILE"
  echo "# 🤖 LLM INSTRUCTIONS #" >> "$OUTPUT_FILE"
  echo "# #" >> "$OUTPUT_FILE"
  echo "################################################################################" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "$LLM_PROMPT" >> "$OUTPUT_FILE"
fi

echo ""
echo "✅ Done! Context and instructions saved to $OUTPUT_FILE"
echo "📊 Total size: $(wc -c < "$OUTPUT_FILE") bytes"