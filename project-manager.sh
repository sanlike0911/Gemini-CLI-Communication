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
        if [ -f "$project_dir/project.json" ]; then
            # jqが使えない場合のシンプルなJSON解析
            local description=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "説明なし")
            local category=$(grep -o '"category"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"category"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
            local version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_dir/project.json" 2>/dev/null | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
            
            echo "  $num. $project_name"
            echo "     📝 $description"
            if [ -n "$category" ]; then
                echo "     🏷️  カテゴリ: $category"
            fi
            if [ -n "$version" ]; then
                echo "     📦 バージョン: $version"
            fi
        else
            echo "  $num. $project_name"
            echo "     📝 (project.json が見つかりません)"
        fi
        echo ""
    done
    
    echo "選択肢:"
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
    
    # プロジェクト固有の指示書をシンボリックリンク
    rm -rf ./instructions 2>/dev/null || true
    ln -sf "$project_dir/instructions" ./instructions
    
    # 作業ディレクトリの準備
    mkdir -p "$project_dir/workspace"
    rm -rf ./workspace 2>/dev/null || true
    ln -sf "$project_dir/workspace" ./workspace
    
    log_success "✅ プロジェクト '$project_name' を選択しました"
    echo "📁 プロジェクトディレクトリ: $project_dir"
    echo "📋 指示書: ./instructions/"
    echo "💼 作業ディレクトリ: ./workspace/"
}

# 現在のプロジェクト表示（シンボリックリンクベース）
show_current() {
    if [ ! -L "./instructions" ]; then
        echo "現在選択されているプロジェクトはありません"
        echo ""
        list_projects
        return 1
    fi
    
    local instructions_link=$(readlink "./instructions")
    local project_dir=$(dirname "$instructions_link")
    local current_project=$(basename "$project_dir")
    
    if [ ! -d "$project_dir" ]; then
        log_warning "リンクされたプロジェクト '$current_project' が見つかりません"
        rm -f "./instructions" "./workspace"
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
    if [ ! -L "./instructions" ]; then
        log_error "プロジェクトが選択されていません"
        echo "プロジェクトを選択してください: $0 select [プロジェクト名]"
        exit 1
    fi
    
    local instructions_link=$(readlink "./instructions")
    local project_dir=$(dirname "$instructions_link")
    local current_project=$(basename "$project_dir")
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