# Writer500 Beta Tester Guide (macOS)

This guide walks you through installing Xcode, downloading the Writer500 source code, building it locally, and (optionally) exporting a standalone `Writer500.app` you can copy into your `/Applications` folder.

This beta does **not** require enrollment in the Apple Developer Program.

---

# Requirements

- macOS (most recent version)
- Xcode installed (see below)
- An Apple ID

---

## 1) Xcode Install and Launch

If you don't already have Xcode installed, find it in the **App Store** and install. After installation completes, open **Xcode**.

On first launch:
- Accept the Xcode license agreement if prompted
- If Xcode prompts to install additional components, choose the **macOS** option and continue (you may be asked for your Mac password)

---

## 2) Sign into Xcode with an Apple ID (required for code signing during builds)

Xcode requires an Apple ID so it can sign the app when it builds it.

1. In Xcode, open **Settings**: **Xcode → Settings**
2. Click **Apple Accounts**
3. Click **Add Apple Account**
4. Choose **Apple Account**
5. Sign in with your Apple ID

After signing in, Xcode will automatically create a **Personal Team** for you. This comes into play later.

---

## 3) Download the source code from GitHub

Get the code onto your Mac. Either download the ZIP file and extract it somewhere, or clone the repo. Whichever you prefer.

---

## 4) Open the project in Xcode

1. In Xcode, choose **File → Open…**
2. Navigate to the `Writer500` folder you downloaded or cloned
3. Open `Writer500.xcodeproj` at the top level of the folder

---

## 5) Select the scheme and run destination

In Xcode's top toolbar:

- Scheme: **Writer500**
- Run destination: **My Mac**

---

## 6) Fix code signing (first run only)

1. In Xcode's left sidebar, click the **blue project icon** at the top (labeled **Writer500**)
2. In the main panel that opens up, select **TARGETS → Writer500** (left side of that sub-panel)
3. Click **Signing & Capabilities**
4. Enable **Automatically manage signing** (if it is not already enabled)
5. For **Team**, select your **Personal Team** (your Apple ID, if it is not already selected)
6. If Xcode displays a **Fix Issue** button, click it

---

## 7) Build and run

- Click the **Run** button (▶︎) in the top-left of Xcode  
  or  
- Press **Command + R**

The first build may take a few minutes. When it finishes, Writer500 should launch automatically.

---

## Optional: Export a standalone `Writer500.app` to `/Applications`

**Important:** Without enrollment in the paid Apple Developer Program, you cannot create a redistributable app for other Macs. However, you *can* export or copy a local `.app` for your own machine. This works because you signed the build of that app with the same ID as you have running on your machine.

---

### A) Create an Archive

1. Confirm in Xcode:
   - Scheme: **Writer500**
   - Destination: **My Mac**
2. From the menu bar, choose **Product → Clean Build Folder**  
   (hold **Option** to switch this item to Clean Build Folder Immediately)
3. Choose **Product → Archive**

Xcode will build a Release archive and open the **Organizer** window with the **Archives** menu selected.

If Organizer does not open automatically:
- Choose **Window → Organizer**
- Select **Archives** on the left

---

### B) Export the `.app`

1. In **Organizer → Archives**, select the newest **Writer500** archive
2. Click **Distribute App**
3. Choose **Custom** and click **Next**
4. Choose **Copy App** and click **Next**
5. Select your /Applications folder in the final screen and click **Export**

---

### C) First launch from `/Applications`

The first time you open the app from `/Applications`, macOS may show a warning.

If so:
1. Right-click `Writer500.app`
2. Choose **Open**
3. Click **Open** again in the confirmation dialog
