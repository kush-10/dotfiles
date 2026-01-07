#!/usr/bin/env bash
set -euo pipefail

target=""
weights_raw=""
grades_raw=""
config_file=""
save_file="$HOME/.grade-calc"
save_enabled=1
list_only=0
add_grade_value=""
history_file="$HOME/.grade-calc-history"

print_usage() {
  cat <<'EOF'
Usage: grade-calc.sh [options]

Options:
  -f, --file PATH       Read inputs from config file (key=value lines).
  -t, --target NUM      Target overall grade (percent or fraction).
  -w, --weights LIST    Weights, comma/space separated (e.g., "20,80").
  -g, --grades LIST     Grades, comma/space separated; use ? for unknown.
  --save [PATH]         Save inputs to PATH (default: ~/.grade-calc).
  --no-save             Disable saving inputs for this run.
  --add-grade NUM       Fill the first missing grade in the saved file.
  --list                Show saved calculation history.
  -h, --help            Show this help.

Config file keys: target=, weights=, grades=
Grades may be fractions (0-1) or percents (0-100). Weights can be any scale.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

is_number() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ || "$1" =~ ^[.][0-9]+$ ]]
}

expand_path() {
  local p="$1"
  if [[ "$p" == "~"* ]]; then
    p="${p/#\~/$HOME}"
  fi
  printf '%s' "$p"
}

read_config() {
  local file="$1"
  [[ -f "$file" ]] || die "Config file not found: $file"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(trim "$line")"
    [[ -z "$line" ]] && continue
    [[ "$line" == *"="* ]] || die "Invalid config line: $line"
    local key="${line%%=*}"
    local val="${line#*=}"
    key="$(trim "$key")"
    val="$(trim "$val")"
    case "$key" in
      target) config_target="$val" ;;
      weights) config_weights_raw="$val" ;;
      grades) config_grades_raw="$val" ;;
      *) die "Unknown config key: $key" ;;
    esac
  done < "$file"
}

write_config() {
  local file="$1"
  local target_val="$2"
  local weights_val="$3"
  local grades_val="$4"
  cat > "$file" <<EOF
target=$target_val
weights=$weights_val
grades=$grades_val
EOF
}

append_history() {
  local result_label="$1"
  local result_value="$2"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s | weights=%s | grades=%s | target=%s | %s=%s\n' \
    "$ts" "$weights_out" "$grades_out_str" "$target" "$result_label" "$result_value" >> "$history_file"
}

join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

format_number() {
  awk -v n="$1" 'BEGIN {
    if (n == int(n)) printf "%d", n;
    else printf "%.2f", n;
  }'
}

require_arg() {
  local opt="$1"
  shift
  [[ $# -gt 0 ]] || die "Missing value for $opt"
  [[ "$1" != -* ]] || die "Missing value for $opt"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      require_arg "$1" "${2:-}"
      config_file="$2"
      shift 2
      ;;
    -t|--target)
      require_arg "$1" "${2:-}"
      target="$2"
      shift 2
      ;;
    -w|--weights)
      require_arg "$1" "${2:-}"
      weights_raw="$2"
      shift 2
      ;;
    -g|--grades)
      require_arg "$1" "${2:-}"
      grades_raw="$2"
      shift 2
      ;;
    --save)
      if [[ ${2:-} =~ ^- ]] || [[ $# -eq 1 ]]; then
        shift
      else
        save_file="$2"
        shift 2
      fi
      ;;
    --no-save)
      save_enabled=0
      shift
      ;;
    --add-grade)
      require_arg "$1" "${2:-}"
      add_grade_value="$2"
      shift 2
      ;;
    --list)
      list_only=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

config_target=""
config_weights_raw=""
config_grades_raw=""

if (( list_only == 1 )); then
  history_file="$(expand_path "$history_file")"
  if [[ -f "$history_file" ]]; then
    cat "$history_file"
  else
    echo "No saved history."
  fi
  exit 0
fi

if [[ -n "$add_grade_value" ]]; then
  is_number "$add_grade_value" || die "Invalid grade: $add_grade_value"
  config_file="${config_file:-$save_file}"
  config_file="$(expand_path "$config_file")"
  read_config "$config_file"
  [[ -n "$config_weights_raw" ]] || die "No weights found in $config_file"
  [[ -n "$config_grades_raw" ]] || die "No grades found in $config_file"
  config_grades_raw="${config_grades_raw//,/ }"
  read -r -a cfg_grades <<< "$config_grades_raw"
  filled=0
  for i in "${!cfg_grades[@]}"; do
    g="$(trim "${cfg_grades[i]}")"
    if [[ -z "$g" || "$g" == "?" ]]; then
      cfg_grades[i]="$add_grade_value"
      filled=1
      break
    fi
  done
  (( filled == 1 )) || die "No missing grade to fill in $config_file"
  grades_out_str="$(join_by "," "${cfg_grades[@]}")"
  write_config "$config_file" "$config_target" "$config_weights_raw" "$grades_out_str"
  echo "Updated $config_file with grade $add_grade_value"
  exit 0
fi

if [[ -n "$config_file" ]]; then
  config_file="$(expand_path "$config_file")"
  read_config "$config_file"
fi

[[ -n "$target" ]] || target="$config_target"
[[ -n "$weights_raw" ]] || weights_raw="$config_weights_raw"
[[ -n "$grades_raw" ]] || grades_raw="$config_grades_raw"

if [[ -z "$weights_raw" ]]; then
  read -r -p "Weights (space/comma separated, e.g., 20 80): " weights_raw
fi
weights_raw="$(trim "$weights_raw")"
weights_raw="${weights_raw//,/ }"
read -r -a weights <<< "$weights_raw"
(( ${#weights[@]} > 0 )) || die "No weights provided"

grades=()
if [[ -n "$grades_raw" ]]; then
  grades_raw="$(trim "$grades_raw")"
  grades_raw="${grades_raw//,/ }"
  read -r -a grades <<< "$grades_raw"
else
  for w in "${weights[@]}"; do
    read -r -p "Grade for weight $w (blank to calculate): " g
    g="$(trim "$g")"
    grades+=("$g")
  done
fi

while (( ${#grades[@]} < ${#weights[@]} )); do
  grades+=("")
done
(( ${#grades[@]} <= ${#weights[@]} )) || die "More grades than weights"

if [[ -z "$target" ]]; then
  read -r -p "Target overall grade (e.g., 60 or 0.6): " target
fi
target="$(trim "$target")"
is_number "$target" || die "Invalid target: $target"

sum_weights=0
known_sum=0
unknown_weight_sum=0
unknown_count=0
unknown_idx=-1

for i in "${!weights[@]}"; do
  w="$(trim "${weights[i]}")"
  is_number "$w" || die "Invalid weight: $w"
  awk -v n="$w" 'BEGIN{exit(n>0?0:1)}' || die "Weight must be > 0: $w"
  sum_weights=$(awk -v a="$sum_weights" -v b="$w" 'BEGIN{print a+b}')

  g="$(trim "${grades[i]}")"
  if [[ -z "$g" || "$g" == "?" ]]; then
    unknown_count=$((unknown_count + 1))
    unknown_idx=$i
    unknown_weight_sum=$(awk -v a="$unknown_weight_sum" -v b="$w" 'BEGIN{print a+b}')
    continue
  fi
  is_number "$g" || die "Invalid grade for weight $w: $g"
  awk -v n="$g" 'BEGIN{exit(n>=0?0:1)}' || die "Grade must be >= 0: $g"
  g_pct=$(awk -v n="$g" 'BEGIN{if (n<=1) print n*100; else print n}')
  known_sum=$(awk -v s="$known_sum" -v ww="$w" -v gg="$g_pct" 'BEGIN{print s + (ww * gg)}')
done

awk -v n="$sum_weights" 'BEGIN{exit(n>0?0:1)}' || die "Total weight must be > 0"

target_pct=$(awk -v n="$target" 'BEGIN{if (n<=1) print n*100; else print n}')

if (( unknown_count == 0 )); then
  overall_pct=$(awk -v s="$known_sum" -v w="$sum_weights" 'BEGIN{print s / w}')
  overall_frac=$(awk -v n="$overall_pct" 'BEGIN{print n/100}')
  result_pct="$(format_number "$overall_pct")"
  result_frac="$(format_number "$overall_frac")"
  echo "Overall grade: $result_pct (percent, $result_frac fraction)"
else
  awk -v n="$unknown_weight_sum" 'BEGIN{exit(n>0?0:1)}' || die "Unknown weights must sum to > 0"
  needed_pct=$(awk -v t="$target_pct" -v w="$sum_weights" -v s="$known_sum" -v uw="$unknown_weight_sum" \
    'BEGIN{print (t*w - s) / uw}')
  needed_frac=$(awk -v n="$needed_pct" 'BEGIN{print n/100}')
  if (( unknown_count == 1 )); then
    missing_w="${weights[$unknown_idx]}"
    result_pct="$(format_number "$needed_pct")"
    result_frac="$(format_number "$needed_frac")"
    echo "Required grade for weight $missing_w: $result_pct (percent, $result_frac fraction)"
  else
    result_pct="$(format_number "$needed_pct")"
    result_frac="$(format_number "$needed_frac")"
    echo "Average grade needed across remaining weights: $result_pct (percent, $result_frac fraction)"
    echo "Note: multiple unknown grades; many combinations are possible."
  fi
  if awk -v n="$needed_pct" 'BEGIN{exit(n<0 || n>100 ? 0:1)}'; then
    echo "Warning: required grade is outside 0-100 percent." >&2
  fi
fi

grades_out=()
for g in "${grades[@]}"; do
  if [[ -z "$g" || "$g" == "?" ]]; then
    grades_out+=("?")
  else
    grades_out+=("$g")
  fi
done
weights_out="$(join_by "," "${weights[@]}")"
grades_out_str="$(join_by "," "${grades_out[@]}")"

if (( save_enabled == 1 )); then
  save_file="$(expand_path "$save_file")"
  write_config "$save_file" "$target" "$weights_out" "$grades_out_str"
  echo "Saved inputs to $save_file"
fi

history_file="$(expand_path "$history_file")"
if (( unknown_count == 0 )); then
  append_history "overall" "$result_pct"
else
  append_history "needed" "$result_pct"
fi
