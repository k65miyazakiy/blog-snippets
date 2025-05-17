#!/bin/bash

# Reiwa K8s the Hard Way - 連番スクリプト一括実行ツール
# このスクリプトは/home/kussaka/projects/blog-snippets/2025/reiwa-k8s-hard-way/scripts配下にある
# すべての連番スクリプトを順番に実行します。

set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
LOGFILE="${SCRIPT_DIR}/run-all.log"

# ログファイルの初期化
> "${LOGFILE}"

# ログ関数
log() {
  local message="$1"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] $message"
  echo -e "[$timestamp] $message" >> "${LOGFILE}"
}

# スクリプト実行関数
run_script() {
  local script_path="$1"
  
  # スクリプトの実行可能確認と無視条件チェック
  if [[ ! -x "${script_path}" ]]; then
    chmod +x "${script_path}"
  fi
  
  local script_basename=$(basename "${script_path}")
  log "実行: ${script_path}"
  
  bash "${script_path}"
  local exit_code=$?
  
  if [[ ${exit_code} -eq 0 ]]; then
    log "完了: ${script_path} (成功)"
  else
    log "エラー: ${script_path} (終了コード: ${exit_code})"
    return ${exit_code}
  fi
}

# ディレクトリ内のスクリプトを実行
run_scripts_in_dir() {
  local dir_path="$1"
  
  log "ディレクトリ処理開始: ${dir_path}"
  
  # 連番スクリプトを正しい順序で取得
  local scripts=()
  while IFS= read -r script; do
    if [[ -f "${script}" && "${script}" == *".sh" && $(basename "${script}") =~ ^[0-9]+ ]]; then
      scripts+=("${script}")
    fi
  done < <(find "${dir_path}" -maxdepth 1 -type f -name "*.sh" | sort)
  
  # スクリプトを順番に実行
  for script in "${scripts[@]}"; do
    run_script "${script}"
    if [[ $? -ne 0 ]]; then
      log "エラーのため処理を中断します"
      return 1
    fi
  done
  
  log "ディレクトリ処理完了: ${dir_path}"
}

# メイン処理
main() {
  log "Reiwa K8s the Hard Way - 一括実行開始"
  
  # トップレベルの連番スクリプトを実行
  run_scripts_in_dir "${SCRIPT_DIR}"
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # サブディレクトリ内のスクリプトを実行
  while IFS= read -r subdir; do
    local dir_name=$(basename "${subdir}")
    # 数字で始まるディレクトリ名のみ処理
    if [[ "${dir_name}" =~ ^[0-9]+ ]]; then
      run_scripts_in_dir "${subdir}"
      if [[ $? -ne 0 ]]; then
        return 1
      fi
    fi
  done < <(find "${SCRIPT_DIR}" -mindepth 1 -maxdepth 1 -type d | sort)
  
  log "Reiwa K8s the Hard Way - 一括実行完了"
}

# 実行
main
exit $?
