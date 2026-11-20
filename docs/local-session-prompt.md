# ローカルの Claude Code に貼り付ける指示文

PC の Claude デスクトップアプリ → Code（ローカル）で、フォルダ `C:\Users\logic\codex-export` を開いて、以下をそのまま貼り付ける。

---

このフォルダは `C:\Users\logic\.codex`（Codex CLI）から、秘密情報を除いてコピーしたものです。
手順書は https://github.com/Take321tomato/O29 の `docs/codex-migration.md`（ブランチ `claude/mobile-claudecode-setup-zx4yrq`）にあります。日本語で進めてください。

1. `_inventory.csv` と各ファイルを読み、私がこれまで Codex でどんな AI 活動をしてきたか（よく扱ったプロジェクト・言語・作業の種類・使っていた MCP やスキル・独自ルール）をまとめて `activity-report.md` に書いてください。
2. 秘密情報（API キー、トークン、パスワード、個人情報）を見つけたら、内容は表示せずに場所だけ報告し、作業を止めて私に確認してください。
3. 元の `C:\Users\logic\.codex` は読まないでください。特に `auth.json` は絶対に開かないでください。必要なら理由を説明して許可を求めてください。
4. 次の移行案を `migration-plan.md` にまとめ、私の承認を得てから実行してください。
   - `AGENTS.md` → `~/.claude/CLAUDE.md`（既存があれば上書きせず統合案を出す）
   - `prompts/*.md` → `~/.claude/commands/`
   - `skills/` → `~/.claude/skills/`
   - `config.toml` のモデル・承認設定 → `~/.claude/settings.json`、MCP サーバー → `claude mcp add` のコマンド案（キーは私が自分で入れる）
5. `~/.claude` 以下を変更する前には必ず差分を見せて承認を求めてください。
