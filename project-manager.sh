#!/bin/bash

# 🗂️ プロジェクト管理システム
# プロジェクト固有の指示書と設定を管理

set -e

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# プロジェクトディレクトリ（相対パス）
PROJECTS_ROOT="./projects"

# jq無しでagents配列を解析する関数
parse_agents_without_jq() {
    local project_file="$1"
    
    # agents配列内のフィールドのみを抽出（プロジェクト名などを除外）
    # agents配列の行番号範囲を取得
    local agents_start=$(grep -n '"agents"' "$project_file" | cut -d: -f1)
    local agents_end=$(tail -n +$agents_start "$project_file" | grep -n ']' | head -1 | cut -d: -f1)
    agents_end=$((agents_start + agents_end - 1))
    
    # agents配列内のrole, name, modelのみを抽出
    local roles=($(sed -n "${agents_start},${agents_end}p" "$project_file" | grep '"role"' | sed 's/.*"role"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'))
    local names=($(sed -n "${agents_start},${agents_end}p" "$project_file" | grep '"name"' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'))
    local models=($(sed -n "${agents_start},${agents_end}p" "$project_file" | grep '"model"' | sed 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'))
    
    # 配列の要素数を確認
    local count=${#roles[@]}
    
    # 各エージェントの情報を表示
    for ((i=0; i<count; i++)); do
        local role="${roles[$i]}"
        local name="${names[$i]}"
        local model="${models[$i]}"
        
        if [ -n "$role" ] && [ -n "$name" ] && [ -n "$model" ]; then
            local role_icon=""
            case "$role" in
                "president") role_icon="👑 PRESIDENT" ;;
                "boss1") role_icon="🎯 boss1" ;;
                *) role_icon="⚡ $role" ;;
            esac
            echo "     $role_icon │ $name │ $model"
        fi
    done
}

# プロジェクトディレクトリ作成
ensure_projects_dir() {
    if [ ! -d "$PROJECTS_ROOT" ]; then
        log_info "プロジェクトディレクトリを作成中: $PROJECTS_ROOT"
        mkdir -p "$PROJECTS_ROOT"
    fi
}

# プロジェクト一覧表示
list_projects() {
    ensure_projects_dir
    
    echo "📁 利用可能なプロジェクト:"
    echo "=========================="
    
    if [ -z "$(ls -A "$PROJECTS_ROOT" 2>/dev/null)" ]; then
        echo "  (プロジェクトが見つかりません)"
        echo ""
        echo "  新しいプロジェクトを作成: $0 create [プロジェクト名]"
        return 1
    fi
    
    for project in "$PROJECTS_ROOT"/*; do
        if [ -d "$project" ]; then
            local project_name=$(basename "$project")
            echo "  📂 $project_name"
        fi
    done
    echo ""
}

# プロジェクト選択UI
select_project_interactive() {
    echo "📂 プロジェクト選択"
    echo "=================="
    
    ensure_projects_dir
    
    # プロジェクト一覧を配列で取得
    local projects=()
    local project_count=0
    
    for project in "$PROJECTS_ROOT"/*; do
        if [ -d "$project" ]; then
            local project_name=$(basename "$project")
            projects+=("$project_name")
            project_count=$((project_count + 1))
        fi
    done
    
    if [ $project_count -eq 0 ]; then
        echo "  (プロジェクトが見つかりません)"
        echo ""
        echo "📁 プロジェクトディレクトリ: $PROJECTS_ROOT"
        echo "   手動でプロジェクトディレクトリを作成してください"
        echo ""
        echo "例: mkdir -p $PROJECTS_ROOT/my-project"
        echo "    mkdir -p $PROJECTS_ROOT/my-project/instructions"
        echo "    mkdir -p $PROJECTS_ROOT/my-project/workspace"
        return 1
    fi
    
    # プロジェクト一覧表示
    echo "利用可能なプロジェクト:"
    for i in "${!projects[@]}"; do
        local num=$((i + 1))
        local project_name="${projects[$i]}"
        local project_dir="$PROJECTS_ROOT/$project_name"
        
        # プロジェクト情報を表示
        echo "  $num. 📂 $project_name"
        echo "     ══════════════════════════════════════════════════"
        
        if [ -f "$project_dir/project.json" ]; then
            # jqが使えない場合のシンプルなJSON解析
            local description=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "説明なし")
            local category=$(grep -o '"category"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"category"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
            local version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
            
            echo "     📝 $description"
            if [ -n "$category" ]; then
                echo "     🏷️  カテゴリ: $category"
            fi
            if [ -n "$version" ]; then
                echo "     📦 バージョン: $version"
            fi
            echo ""
            
            # エージェント設定情報を表示
            echo "     👥 エージェント構成:"
            
            # jqが利用可能な場合
            if command -v jq &> /dev/null; then
                jq -r '.agents[] | "     \(.role | if . == \"president\" then \"👑 PRESIDENT\" elif . == \"boss1\" then \"🎯 boss1\" else \"⚡ \(.)\" end) │ \(.name) │ \(.model)"' "$project_dir/project.json" 2>/dev/null || {
                    echo "     ❌ エージェント情報の読み込みに失敗しました"
                }
            else
                # jqが使えない場合は自作の解析関数を使用
                parse_agents_without_jq "$project_dir/project.json"
            fi
            
            echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        else
            echo "     ❌ project.json が見つかりません"
            echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
        echo ""
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 選択肢:"
    echo "  1-$project_count: プロジェクトを選択"
    echo "  0: 終了"
    echo ""
    
    while true; do
        read -p "プロジェクト番号を選択 (0-$project_count): " choice
        
        if [ "$choice" = "0" ]; then
            echo "終了します"
            return 1
        elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -le "$project_count" ]; then
            local selected_project="${projects[$((choice - 1))]}"
            select_project "$selected_project"
            return 0
        else
            log_error "無効な選択です。0-$project_count の数字を入力してください。"
        fi
    done
}

# プロジェクト選択
select_project() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        log_error "プロジェクト名を指定してください"
        echo "利用可能なプロジェクト:"
        list_projects
        exit 1
    fi
    
    local project_dir="$PROJECTS_ROOT/$project_name"
    
    if [ ! -d "$project_dir" ]; then
        log_error "プロジェクト '$project_name' が見つかりません"
        echo ""
        list_projects
        exit 1
    fi
    
    # 作業ディレクトリの準備
    mkdir -p "$project_dir/workspace"
    
    # 選択されたプロジェクトを設定ファイルに記録
    echo "$project_name" > .current-project
    
    log_success "✅ プロジェクト '$project_name' を選択しました"
    echo "📁 プロジェクトディレクトリ: $project_dir"
    echo "📋 指示書: $project_dir/instructions/"
    echo "💼 作業ディレクトリ: $project_dir/workspace/"
}

# 現在のプロジェクト表示
show_current() {
    if [ ! -f ".current-project" ]; then
        echo "現在選択されているプロジェクトはありません"
        echo ""
        list_projects
        return 1
    fi
    
    local current_project=$(cat ".current-project")
    local project_dir="$PROJECTS_ROOT/$current_project"
    
    if [ ! -d "$project_dir" ]; then
        log_warning "設定されたプロジェクト '$current_project' が見つかりません"
        rm -f ".current-project"
        return 1
    fi
    
    echo "📂 現在のプロジェクト: $current_project"
    echo "📍 場所: $project_dir"
    
    echo ""
    echo "📋 利用可能なコマンド:"
    echo "  ./launch-president.sh  # PRESIDENT起動"
    echo "  ./launch-team.sh       # チーム起動"
    echo "  ./project-manager.sh edit  # 指示書編集"
}

# 指示書編集
edit_instructions() {
    if [ ! -f ".current-project" ]; then
        log_error "プロジェクトが選択されていません"
        echo "プロジェクトを選択してください: $0 select [プロジェクト名]"
        exit 1
    fi
    
    local current_project=$(cat ".current-project")
    local project_dir="$PROJECTS_ROOT/$current_project"
    local instructions_dir="$project_dir/instructions"
    
    echo "📝 指示書編集: $current_project"
    echo "=========================="
    echo "1. president.md - PRESIDENT指示書"
    echo "2. boss.md      - boss1指示書"
    echo "3. worker.md    - worker1-3指示書"
    echo "4. 戻る"
    echo ""
    
    read -p "編集するファイルを選択 (1-4): " choice
    
    case $choice in
        1)
            ${EDITOR:-nano} "$instructions_dir/president.md"
            ;;
        2)
            ${EDITOR:-nano} "$instructions_dir/boss.md"
            ;;
        3)
            ${EDITOR:-nano} "$instructions_dir/worker.md"
            ;;
        4)
            return 0
            ;;
        *)
            log_error "無効な選択です"
            ;;
    esac
}

# 使用方法表示
show_usage() {
    cat << 'EOF'
🗂️ プロジェクト管理システム

使用方法:
  ./project-manager.sh                         # 対話式プロジェクト選択
  ./project-manager.sh list                    # プロジェクト一覧表示
  ./project-manager.sh select                  # 対話式プロジェクト選択
  ./project-manager.sh select [プロジェクト名]   # プロジェクト直接選択
  ./project-manager.sh current                 # 現在のプロジェクト表示
  ./project-manager.sh edit                    # 指示書編集

例:
  ./project-manager.sh                         # 対話式選択
  ./project-manager.sh select programming-organization  # 直接選択
  ./project-manager.sh edit                    # 指示書編集

プロジェクト構造:
  ./projects/[プロジェクト名]/
  ├── instructions/          # 指示書
  │   ├── president.md
  │   ├── boss.md
  │   └── worker.md
  └── workspace/            # 作業ディレクトリ

注意: プロジェクトは手動で作成してください
例: mkdir -p ./projects/my-project/{instructions,workspace}

EOF
}

# メイン処理
main() {
    case "${1:-}" in
        "list"|"ls")
            list_projects
            ;;
        "select")
            if [ -z "$2" ]; then
                select_project_interactive
            else
                select_project "$2"
            fi
            ;;
        "current")
            show_current
            ;;
        "edit")
            edit_instructions
            ;;
        "--help"|"-h"|"help")
            show_usage
            ;;
        "")
            select_project_interactive
            ;;
        *)
            log_error "不明なコマンド: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 実行
main "$@"