# Lottie Setup Guide

## 📦 Lottie SDK Installation

### Step 1: Add Lottie via Swift Package Manager

1. Open `HaushaltsHero.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter URL: `https://github.com/airbnb/lottie-ios`
4. Select version: **4.3.0** or later
5. Add to target: **HaushaltsHero**

### Step 2: Enable Lottie in Code

In `LottieView.swift`:
1. Uncomment the `#if LOTTIE_ENABLED` block
2. Comment out the placeholder implementation
3. Build and verify no errors

### Step 3: Add Lottie Animation Files

Download animations from [LottieFiles.com](https://lottiefiles.com):

**Required Animations:**

| File | Purpose | Download Link |
|------|---------|---------------|
| `confetti.json` | Quest Complete, High Score | [Search: confetti](https://lottiefiles.com/search?q=confetti) |
| `level_up.json` | Streak Milestone | [Search: level up](https://lottiefiles.com/search?q=level%20up) |
| `loading_spinner.json` | Scoring Phase | [Search: loading](https://lottiefiles.com/search?q=loading) |
| `checkmark_success.json` | Success Feedback | [Search: checkmark](https://lottiefiles.com/search?q=checkmark) |
| `sparkles.json` | Heatmap Overlay | [Search: sparkles](https://lottiefiles.com/search?q=sparkles) |

**Hero Character Animations:**

| File | Emotion | Usage |
|------|---------|-------|
| `hero_happy.json` | Happy | Score 70-85 |
| `hero_celebrating.json` | Celebrating | Score 85+ |
| `hero_thinking.json` | Thinking | Scoring Phase |
| `hero_encouraging.json` | Encouraging | Score <70 |
| `hero_tired.json` | Tired | Long Inactivity |

### Step 4: Add to Xcode Project

1. Create folder: `HaushaltsHero/Resources/Media/Animations/`
2. Drag all `.json` files into this folder
3. Ensure **"Copy items if needed"** is checked
4. Add to target: **HaushaltsHero**

### Step 5: Verify Integration

Run the app and check:
- ✅ Hero character appears in ScoreResultView
- ✅ Confetti plays for scores ≥85
- ✅ No console warnings about missing animations

---

## 🎨 Alternative: Use Placeholders

If you prefer **not to use Lottie** (keeps bundle smaller):

The app already uses **SF Symbols as placeholders**:
- Hero → `figure.wave`
- Confetti → `party.popper.fill`
- Loading → `arrow.triangle.2.circlepath`
- Success → `checkmark.circle.fill`
- Sparkles → `sparkles`

**No action needed** - placeholders work out of the box!

---

## 📊 Bundle Size Impact

| Option | Bundle Size Increase |
|--------|---------------------|
| Lottie SDK Only | +2 MB |
| + 10 Animations | +3-5 MB |
| **Total** | **+5-7 MB** |

SF Symbols (Placeholder): **+0 MB**

---

## 🔧 Troubleshooting

**Problem:** "Lottie animation not found"
- **Solution:** Check file names match exactly (case-sensitive)
- Verify files are in `Resources/Media/Animations/`

**Problem:** Animations don't play
- **Solution:** Ensure Lottie SDK is added to target
- Check Xcode console for errors

**Problem:** Build fails after adding Lottie
- **Solution:** Clean build folder (Cmd+Shift+K)
- Restart Xcode

---

## 📚 Resources

- [Lottie iOS Documentation](https://github.com/airbnb/lottie-ios)
- [LottieFiles.com](https://lottiefiles.com) - Free animations
- [Lottie Editor](https://lottiefiles.com/editor) - Customize animations

---

**Created by:** AI Agent
**Last Updated:** 2025-11-19
