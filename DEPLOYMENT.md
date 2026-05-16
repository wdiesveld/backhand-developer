# Backhand Developer - Static Site Deployment Guide

## Overview

This is a static site built with **11ty (Eleventy)** and ready for GitHub Pages hosting. The site includes interactive visualizations using D3.js and Chart.js.

## Local Development

```bash
# Install dependencies
npm install

# Start development server (localhost:8080)
npm run dev

# Build for production
npm run build
```

The development server watches for changes and auto-reloads.

## Deployment to GitHub Pages

### Option 1: Automated Deployment (Recommended)

The project includes a GitHub Actions workflow (`.github/workflows/deploy.yml`) that automatically:
1. Builds the site on every push to `main` branch
2. Deploys to GitHub Pages

**Steps:**

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Add 11ty static site and GitHub Actions deployment"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repo → Settings → Pages
   - Set Source to "Deploy from a branch"
   - Select `gh-pages` branch
   - Click Save

3. **Watch the deployment:**
   - Go to Actions tab in GitHub
   - Wait for workflow to complete (1-2 minutes)
   - Your site is now live!

### Option 2: Manual Deployment

1. Build locally:
   ```bash
   npm run build
   ```

2. Push `dist/` folder to your GitHub Pages repository

## Project Structure

```
app/
├── _includes/
│   └── base.njk          # Base layout template
├── _data/                # Data directory
├── index.njk             # Home page
├── rankings-streamgraph.njk
├── under-pressure-rating.njk
├── css/
├── js/
├── images/
└── data/                 # JSON data files
dist/                     # Generated static site (deployed to GitHub Pages)
.github/workflows/
└── deploy.yml            # GitHub Actions workflow
```

## Updating the Site

1. **Edit templates** in `app/` folder
2. **Commit and push** to GitHub
3. **GitHub Actions** automatically rebuilds and deploys
4. Site updates within ~1 minute

## Technology Stack

- **Static Generator:** Eleventy (11ty) v3
- **Template Language:** Nunjucks
- **CSS Framework:** Bootstrap 4.4.1
- **Visualizations:** D3.js v6, Chart.js
- **Deployment:** GitHub Pages with GitHub Actions

## Troubleshooting

**Site not updating after push?**
- Check GitHub Actions tab for workflow status
- Look for build errors in workflow logs
- Verify `.github/workflows/deploy.yml` exists

**404 errors on subpages?**
- GitHub Pages requires proper permalink configuration in 11ty
- All pages should have proper `permalink` front matter

**Images/CSS not loading?**
- Verify assets are in `dist/` folder
- Check that URLs use `/` prefix (absolute paths)

## References

- [Eleventy Documentation](https://www.11ty.dev/)
- [GitHub Pages Docs](https://docs.github.com/en/pages)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
