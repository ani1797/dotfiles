---
layout: default
title: Publishing to GitHub Pages
nav_order: 99
---

# Publishing Documentation to GitHub Pages

This guide explains how to publish this documentation to GitHub Pages.

## Quick Start

### Option 1: GitHub Pages from `/docs` folder (Recommended)

1. Push your repository to GitHub
2. Go to repository Settings → Pages
3. Under "Build and deployment":
   - **Source**: Deploy from a branch
   - **Branch**: `main` (or `master`)
   - **Folder**: `/docs`
4. Click "Save"
5. Your site will be available at `https://<username>.github.io/<repository>/`

### Option 2: GitHub Actions (Advanced)

Create `.github/workflows/jekyll.yml`:

```yaml
name: Deploy Jekyll site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Build with Jekyll
        uses: actions/jekyll-build-pages@v1
        with:
          source: ./docs
          destination: ./_site
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

Then in Settings → Pages, select "GitHub Actions" as the source.

## Local Testing

Test the site locally before publishing:

```bash
# Install dependencies (first time only)
cd docs
bundle install

# Serve the site locally
bundle exec jekyll serve

# With live reload
bundle exec jekyll serve --livereload

# With drafts included
bundle exec jekyll serve --drafts
```

Visit http://localhost:4000 to preview.

## Documentation Structure

The documentation is organized for optimal GitHub Pages compatibility:

```
docs/
├── _config.yml              # Jekyll configuration
├── index.md                 # Home page (auto-generated from this file)
├── Gemfile                  # Ruby dependencies
├── .gitignore              # Ignore build files
│
├── modules/                # Module documentation
│   ├── bash.md
│   ├── git.md
│   ├── zsh.md
│   └── ...
│
├── 1password-integration.md # Integration guides
├── structure.md            # Repository structure
└── PUBLISHING.md           # This file
```

## Customization

### Changing Theme

Edit `docs/_config.yml`:

```yaml
theme: jekyll-theme-cayman
```

Available GitHub-supported themes:
- `jekyll-theme-cayman` (default)
- `jekyll-theme-minimal`
- `jekyll-theme-slate`
- `jekyll-theme-architect`
- `jekyll-theme-dinky`
- `jekyll-theme-hacker`
- `jekyll-theme-leap-day`
- `jekyll-theme-merlot`
- `jekyll-theme-midnight`
- `jekyll-theme-minima`
- `jekyll-theme-modernist`
- `jekyll-theme-primer`
- `jekyll-theme-slate`
- `jekyll-theme-tactile`
- `jekyll-theme-time-machine`

For advanced themes, use a remote theme:

```yaml
remote_theme: just-the-docs/just-the-docs
```

### Custom Domain

1. Add a file `docs/CNAME` with your domain:
   ```
   docs.example.com
   ```

2. Configure DNS:
   - Add a CNAME record pointing to `<username>.github.io`
   - Or A records pointing to GitHub's IPs

3. Enable "Enforce HTTPS" in Settings → Pages

### Adding Navigation

Edit `docs/_config.yml`:

```yaml
navigation:
  - title: Home
    url: /
  - title: Modules
    url: /modules/
  - title: Guides
    url: /guides/
```

### Adding Search

Add to `_config.yml`:

```yaml
plugins:
  - jekyll-search
```

## Front Matter

Each markdown file can have YAML front matter for metadata:

```yaml
---
layout: default
title: Page Title
nav_order: 1
description: "Page description for SEO"
parent: Parent Page (optional)
---
```

## Markdown Extensions

GitHub Pages supports GitHub Flavored Markdown (GFM):

### Syntax Highlighting

```ruby
def hello
  puts "Hello, world!"
end
```

### Task Lists

- [x] Completed task
- [ ] Incomplete task

### Tables

| Module | Status | Priority |
|--------|--------|----------|
| Git    | ✓      | High     |
| Zsh    | ✓      | High     |

### Alerts (GitHub-style)

> **Note**
> This is a note.

> **Warning**
> This is a warning.

### Emoji

:rocket: :tada: :sparkles:

## Troubleshooting

### Build Failures

Check the Actions tab for build logs if using GitHub Actions.

Common issues:
- **Invalid YAML front matter**: Ensure proper formatting
- **Liquid syntax errors**: Check template tags
- **Missing dependencies**: Update Gemfile

### Local Build Issues

```bash
# Clear cache
bundle exec jekyll clean

# Update dependencies
bundle update

# Verbose output
bundle exec jekyll serve --verbose
```

### Links Not Working

- Use relative links: `[Link](../page)` not `[Link](/page)`
- Enable `jekyll-relative-links` plugin
- Test locally before pushing

## Best Practices

1. **Test locally** before pushing
2. **Use relative links** for portability
3. **Add front matter** to all pages
4. **Keep navigation simple** and organized
5. **Update _config.yml** when adding major sections
6. **Use descriptive titles** and headings
7. **Add table of contents** to long pages
8. **Include code examples** where helpful
9. **Link between related pages**
10. **Update last modified dates**

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/)
- [Jekyll Themes](https://pages.github.com/themes/)

## Maintenance

### Regular Updates

- Review and update documentation when modules change
- Test links periodically
- Update dependency versions
- Check for broken links
- Update screenshots if UI changes

### Version Control

- Commit documentation changes separately from code
- Use meaningful commit messages
- Review diffs before pushing
- Keep a CHANGELOG for major updates

---

**Need help?** Open an issue in the repository.
