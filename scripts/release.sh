#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# バージョン番号を引数として受け取る
VERSION=$1

if [ -z "$VERSION" ]; then
    print_error "Usage: $0 <version>"
    print_info "Example: $0 v1.0.0"
    exit 1
fi

# バージョン形式の検証 (vX.Y.Z)
if ! [[ $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Please use the format vX.Y.Z (e.g., v1.0.0)"
    exit 1
fi

# 現在のブランチがmainであることを確認
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "You are not on the main branch. Current branch: $CURRENT_BRANCH"
    read -p "Do you want to continue anyway? (y/N): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        print_info "Release aborted"
        exit 0
    fi
fi

# 未コミットの変更がないか確認
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes"
    git status --short
    read -p "Do you want to continue anyway? (y/N): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        print_info "Release aborted"
        exit 0
    fi
fi

# 前回のタグを取得
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
print_info "Previous tag: ${LAST_TAG:-None}"

# リリースノートを生成
generate_release_notes() {
    local from_tag="$1"
    local to_ref="HEAD"
    local notes=""

    if [ -z "$from_tag" ]; then
        notes="## 🎉 Initial Release"
    else
        notes="## 🚀 Changes since $from_tag\n\n"
        
        # コミットを分類してリリースノートを生成
        notes+="### ✨ New Features\n"
        local feat_commits=$(git log "$from_tag..$to_ref" --pretty=format:"- %s" --grep="^feat:" 2>/dev/null)
        notes+="${feat_commits:-None}"
        
        notes+="\n\n### 🐛 Bug Fixes\n"
        local fix_commits=$(git log "$from_tag..$to_ref" --pretty=format:"- %s" --grep="^fix:" 2>/dev/null)
        notes+="${fix_commits:-None}"
        
        notes+="\n\n### 📚 Documentation\n"
        local docs_commits=$(git log "$from_tag..$to_ref" --pretty=format:"- %s" --grep="^docs:" 2>/dev/null)
        notes+="${docs_commits:-None}"
        
        notes+="\n\n### 🔧 Maintenance\n"
        local chore_commits=$(git log "$from_tag..$to_ref" --pretty=format:"- %s" --grep="^chore:" 2>/dev/null)
        notes+="${chore_commits:-None}"
        
        # その他のコミット
        notes+="\n\n### 🔄 Other Changes\n"
        local other_commits=$(git log "$from_tag..$to_ref" --pretty=format:"- %s" --grep -v "^feat:\|^fix:\|^docs:\|^chore:" 2>/dev/null)
        notes+="${other_commits:-None}"
    fi

    echo -e "$notes"
}

# CHANGELOGを更新
update_changelog() {
    local version="$1"
    local notes="$2"
    local date=$(date +%Y-%m-%d)
    local version_without_v="${version#v}"
    
    # CHANGELOGが存在するか確認
    if [ ! -f "CHANGELOG.md" ]; then
        print_warning "CHANGELOG.md not found, creating a new one"
        echo "# Changelog" > CHANGELOG.md
        echo "" >> CHANGELOG.md
        echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
        echo "" >> CHANGELOG.md
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> CHANGELOG.md
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> CHANGELOG.md
        echo "" >> CHANGELOG.md
    fi
    
    # 新しいバージョンのエントリを追加
    local temp_file=$(mktemp)
    awk -v version="$version_without_v" -v date="$date" '
    /^## / { if (!found) { print "## [" version "] - " date "\n"; found=1; } }
    { print }
    !/^## / && !found && NR > 6 { print "## [" version "] - " date "\n"; found=1; }
    END { if (!found) { print "## [" version "] - " date "\n"; } }
    ' CHANGELOG.md > "$temp_file"
    
    # 変更内容を追加
    local formatted_notes=$(echo -e "$notes" | sed 's/^## 🚀 Changes since.*$//')
    sed -i.bak "s/## \[$version_without_v\] - $date/## [$version_without_v] - $date\n$formatted_notes/" "$temp_file"
    
    # 元のファイルを更新
    mv "$temp_file" CHANGELOG.md
    rm -f CHANGELOG.md.bak
    
    print_success "Updated CHANGELOG.md"
}

# Cargoにログインしているか確認
print_info "Checking cargo login status..."
if ! cargo login --help &>/dev/null; then
    print_error "Please login to crates.io first using 'cargo login'"
    print_info "You can find your API token at https://crates.io/me"
    exit 1
fi

# GitHub CLIがインストールされているか確認
if ! command -v gh &>/dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    print_info "Please install it from https://cli.github.com/"
    exit 1
fi

# GitHub CLIがログインしているか確認
if ! gh auth status &>/dev/null; then
    print_error "Please login to GitHub first using 'gh auth login'"
    exit 1
fi

# Manually fix the Cargo.toml file
print_info "Manually fixing Cargo.toml dependencies..."
cat > Cargo.toml << EOF
[package]
name = "yamori"
version = "0.1.0"
edition = "2021"
authors = ["nwiizo <nwiizo@gmail.com>"]
description = "A test runner and visualizer for command-line applications"
repository = "https://github.com/nwiizo/yamori"
license = "MIT"
readme = "README.md"
keywords = ["testing", "tui", "cli", "visualization"]
categories = ["command-line-utilities", "development-tools::testing"]

[dependencies]

[dependencies.anyhow]
version = "1.0.0"

[dependencies.similar]
version = "2.7.0"

[dependencies.clap]
version = "4.5.0"
features = ["derive"]

[dependencies.crossterm]
version = "0.28.0"

[dependencies.ratatui]
version = "0.29.0"

[dependencies.serde]
version = "1.0.0"
features = ["derive"]

[dependencies.serde_yaml]
version = "0.9"

[dependencies.toml]
version = "0.8"

[dependencies.chrono]
version = "0.4"
EOF

# cargo fmt を実行してフォーマットを整える
print_info "Running cargo fmt..."
cargo fmt || {
    print_error "cargo fmt failed"
    exit 1
}

# cargo clippyを実行してコードをチェック
print_info "Running cargo clippy..."
cargo clippy --all-targets --all-features -- -D warnings || {
    print_error "cargo clippy found issues"
    exit 1
}

# cargo updateを実行してCargo.lockを更新
print_info "Updating dependencies..."
cargo update || {
    print_error "cargo update failed"
    exit 1
}

# 変更をコミット
print_info "Committing version changes..."
git add Cargo.toml Cargo.lock
git commit -m "chore: bump version to $VERSION"

# ビルドとテストを実行
print_info "Building release version..."
cargo build --release || {
    print_error "cargo build failed"
    exit 1
}

print_info "Running tests..."
cargo test || {
    print_error "cargo test failed"
    exit 1
}

# リリースノートを生成
print_info "Generating release notes..."
RELEASE_NOTES=$(generate_release_notes "$LAST_TAG")
echo -e "$RELEASE_NOTES" > /tmp/release_notes.md
print_info "Release notes preview:"
echo -e "$RELEASE_NOTES"

# CHANGELOGを更新
update_changelog "$VERSION" "$RELEASE_NOTES"
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG.md for $VERSION"

# Cargoのパッケージを作成
print_info "Creating cargo package..."
cargo package --allow-dirty || {
    print_error "cargo package failed"
    exit 1
}

# gitタグを作成
print_info "Creating git tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# GitHubリリースを作成
print_info "Creating GitHub release..."
gh release create "$VERSION" \
    --title "Release $VERSION" \
    --notes-file /tmp/release_notes.md \
    --draft \
    target/package/* || {
    print_error "Failed to create GitHub release"
    exit 1
}

# crates.ioにパブリッシュ
print_info "Publishing to crates.io..."
cargo publish --allow-dirty || {
    print_error "Failed to publish to crates.io"
    exit 1
}

# リモートにプッシュ
print_info "Pushing changes to remote repository..."
git push origin main || {
    print_error "Failed to push to main branch"
    exit 1
}

git push origin "$VERSION" || {
    print_error "Failed to push tag"
    exit 1
}

print_success "Release $VERSION completed successfully!"
print_success "- Updated version to $VERSION"
print_success "- Updated CHANGELOG.md"
print_success "- Created GitHub release with auto-generated notes"
print_success "- Published to crates.io"
print_success "- Pushed tags to origin"

# Clean up
rm -f /tmp/release_notes.md 