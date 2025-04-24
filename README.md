<h1 align="center"> Github to itch.io 🚀 <img src="./icon.svg" width=64 align="center"/></h1>

This addon automatically creates a GitHub Actions workflow to publish your game directly to your [itch.io](https://itch.io) project. Perfect for game jams or rapid iteration—get your playable builds online within minutes of pushing to GitHub!

## ⚠️ Disclaimer

This project is heavily inspired by [MeagherGames](https://github.com/MeagherGames/) and their fantastic [Github To Itch](https://github.com/MeagherGames/github_to_itch) project. Huge thanks to them!

---

## 🔧 Setup

1. **Enable the Addon**
   A setup window will pop up with instructions for adding your `BUTLER_API_KEY`—this is required to upload to itch.io.

2. **Configure Your Project Info**
   Enter your itch.io **username** and **project name** in the setup window so Butler knows where to publish.

3. **Create an Export Preset**
   Go to `Project > Export` and create a preset (if you haven't already). The addon will include this in the workflow.

4. **Done! 🎉**
   Every time you push to your main branch, the workflow will automatically build and publish your game to itch.io.
   To change your config later, go to `Project > Tools > Github to Itch Config` or find it under `Project Settings > github_to_itch/config`.

---

## ⚙️ How It Works

- The addon checks for an export preset where `runnable = true`. If found, it sets up a GitHub Actions workflow that exports and uploads your build to itch.io with the correct channel.
- It uses **Semantic Versioning** and **Conventional Commits** to manage version updates based on your commit messages.
- Each successful deployment also creates a **release** on your GitHub repository—great for keeping track of working builds.

---

## ✨ Customization

Need to tweak the workflow?
Edit the template located at:

```
addons/github_to_itch/templates
```

You can change branches, tweak build steps, or add custom actions—make it yours!

---

## 💡 Suggestions & Contributions

Got ideas to improve this addon?
Open an issue or fork the project and submit a PR—we’d love to see what you come up with!
