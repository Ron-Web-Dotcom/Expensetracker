# App Store Connect Configuration Guide

## Complete Step-by-Step Guide to Setting Up Your App in App Store Connect

This guide walks you through the entire process of configuring your app in App Store Connect, from initial setup to submission readiness.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Access App Store Connect](#access-app-store-connect)
3. [Create New App](#create-new-app)
4. [App Information](#app-information)
5. [Pricing and Availability](#pricing-and-availability)
6. [App Privacy](#app-privacy)
7. [Version Information](#version-information)
8. [Build Upload](#build-upload)
9. [Screenshots and Media](#screenshots-and-media)
10. [App Review Information](#app-review-information)
11. [TestFlight Setup](#testflight-setup)
12. [Submit for Review](#submit-for-review)
13. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- ✅ Active Apple Developer Account ($99/year)
- ✅ Bundle ID registered in Developer Portal
- ✅ Signed IPA file ready for upload
- ✅ App icons (1024x1024 PNG)
- ✅ Screenshots for all required device sizes
- ✅ Privacy Policy URL (hosted)
- ✅ Terms of Service URL (hosted)

---

## Access App Store Connect

### Step 1: Sign In

1. Go to https://appstoreconnect.apple.com/
2. Sign in with your Apple Developer account
3. Complete Two-Factor Authentication if prompted

### Step 2: Navigate to My Apps

1. Click "My Apps" from the homepage
2. You'll see a list of your existing apps (if any)

---

## Create New App

### Step 1: Add New App

1. Click the "+" button (top left)
2. Select "New App"

### Step 2: Configure Basic Information

**Platforms:**
- ☑️ iOS
- ☐ tvOS (uncheck if not applicable)

**Name:**
```
ExpenseTracker
```
- This is the name that appears on the App Store
- Maximum 30 characters
- Must be unique across the App Store

**Primary Language:**
```
English (U.S.)
```

**Bundle ID:**
```
com.expensetracker.app
```
- Select from dropdown (must be registered in Developer Portal)

**SKU:**
```
EXPENSETRACKER001
```
- Unique identifier for your app
- Not visible to users
- Cannot be changed after creation
- Use alphanumeric characters only

**User Access:**
```
Full Access
```
- Or "Limited Access" if you want to restrict team members

### Step 3: Create App

Click "Create" to proceed.

---

## App Information

### Step 1: Navigate to App Information

1. Select your app from "My Apps"
2. Click "App Information" in the left sidebar

### Step 2: General Information

**Name:**
```
ExpenseTracker
```

**Subtitle (Optional):**
```
Smart Budget & Expense Manager
```
- Maximum 30 characters
- Appears below app name on App Store

**Privacy Policy URL:**
```
https://expensetra7629.builtwithrocket.new/privacy_policy.html
```
- Must be publicly accessible
- Required for all apps

**Category:**
- **Primary:** Finance
- **Secondary (Optional):** Productivity

**Content Rights:**
```
☐ Contains third-party content
```
- Check only if your app displays content from third parties

**Age Rating:**
Click "Edit" and complete questionnaire:
- Violence: None
- Sexual Content: None
- Profanity: None
- Gambling: None
- Medical/Treatment Info: None
- Alcohol/Tobacco/Drugs: None
- Horror/Fear Themes: None
- Mature/Suggestive Themes: None
- Unrestricted Web Access: No
- Gambling & Contests: No

**Expected Rating:** 4+

### Step 3: Save Changes

Click "Save" in the top right.

---

## Pricing and Availability

### Step 1: Navigate to Pricing

1. Click "Pricing and Availability" in left sidebar

### Step 2: Configure Pricing

**Price:**
```
Free
```
- Or select a price tier if paid app

**Availability:**
```
☑️ Make this app available in all territories
```
- Or select specific countries

**Pre-Order:**
```
☐ Make available for pre-order
```
- Check if you want pre-orders

**App Distribution Methods:**
```
☑️ Public - Available to everyone on the App Store
☐ Private - Available only to specific organizations
```

### Step 3: Save Changes

Click "Save".

---

## App Privacy

### Step 1: Navigate to App Privacy

1. Click "App Privacy" in left sidebar
2. Click "Get Started"

### Step 2: Data Collection

**Do you or your third-party partners collect data from this app?**
```
☑️ Yes
```

### Step 3: Data Types

Select all data types collected:

**Financial Info:**
- ☑️ Purchase History
- ☑️ Payment Info (if storing payment methods)
- ☑️ Other Financial Info (expense data)

**Contact Info:**
- ☑️ Email Address
- ☑️ Name (if collected)

**User Content:**
- ☑️ Photos or Videos (receipt images)
- ☑️ Other User Content (expense descriptions)

**Identifiers:**
- ☑️ User ID
- ☑️ Device ID (for analytics)

**Usage Data:**
- ☑️ Product Interaction (analytics)
- ☑️ Crash Data
- ☑️ Performance Data

**Location:**
- ☑️ Approximate Location (if using location for expenses)

### Step 4: Data Usage

For each data type, specify:

**Purpose:**
- App Functionality
- Analytics
- Product Personalization

**Linked to User:**
```
☑️ Yes - Data is linked to user identity
```

**Used for Tracking:**
```
☐ No - Not used for tracking across apps/websites
```

### Step 5: Privacy Policy

Confirm privacy policy URL:
```
https://expensetra7629.builtwithrocket.new/privacy_policy.html
```

### Step 6: Publish

Click "Publish" to make privacy information public.

---

## Version Information

### Step 1: Navigate to Version

1. Click "iOS App" in left sidebar
2. Click on version number (e.g., "1.0")

### Step 2: What's New in This Version

**Version 1.0 Release Notes:**
```
Welcome to ExpenseTracker!

✨ Features:
• Track expenses and income with ease
• Smart budget management with alerts
• Receipt scanning and storage
• Detailed analytics and insights
• Secure biometric authentication
• Beautiful, intuitive interface
• Export data in multiple formats
• Dark mode support

Start taking control of your finances today!
```
- Maximum 4,000 characters
- Use bullet points for readability
- Highlight key features

### Step 3: Promotional Text (Optional)

```
🎉 Launch Special: Get started with ExpenseTracker and take control of your finances!
```
- Maximum 170 characters
- Can be updated without new version submission
- Appears above description

### Step 4: Description

```
ExpenseTracker is your personal finance companion that makes managing money simple and stress-free.

💰 SMART EXPENSE TRACKING
• Quickly log expenses and income
• Categorize transactions automatically
• Attach receipt photos with OCR
• Tag expenses with location
• Add custom notes and descriptions

📊 BUDGET MANAGEMENT
• Set budgets by category
• Real-time spending alerts
• Visual progress indicators
• Monthly budget comparisons
• Smart spending insights

📈 POWERFUL ANALYTICS
• Interactive charts and graphs
• Spending trends analysis
• Category breakdowns
• Monthly comparisons
• Export reports (PDF, CSV, Excel)

🔒 SECURE & PRIVATE
• Biometric authentication (Face ID, Touch ID)
• AES-256 encryption
• Local data storage
• No ads, no data selling
• GDPR & CCPA compliant

✨ BEAUTIFUL DESIGN
• Intuitive, modern interface
• Dark mode support
• Smooth animations
• Customizable themes
• Accessibility features

🎯 PERFECT FOR:
• Personal finance management
• Budget tracking
• Expense reporting
• Financial goal setting
• Receipt organization

Download ExpenseTracker today and start your journey to financial freedom!

📧 Support: support@expensetracker.app
🌐 Website: https://expensetracker.app
📱 Follow us for tips and updates
```
- Maximum 4,000 characters
- Use emojis sparingly
- Highlight unique features
- Include keywords naturally

### Step 5: Keywords

```
expense,budget,finance,money,tracker,spending,income,receipt,analytics,savings
```
- Maximum 100 characters (including commas)
- No spaces after commas
- No app name or category
- Research competitor keywords

### Step 6: Support URL

```
https://expensetra7629.builtwithrocket.new
```

### Step 7: Marketing URL (Optional)

```
https://expensetracker.app
```

---

## Build Upload

### Step 1: Upload Build

**Option A: Using Xcode Organizer**

1. Open Xcode
2. Window → Organizer
3. Select your archive
4. Click "Distribute App"
5. Select "App Store Connect"
6. Click "Upload"
7. Wait for upload to complete

**Option B: Using Command Line**

```bash
xcrun altool --upload-app \
  --type ios \
  --file "build/ios/ipa/Runner.ipa" \
  --username "your-apple-id@example.com" \
  --password "your-app-specific-password"
```

**Option C: Using Transporter App**

1. Download Transporter from Mac App Store
2. Sign in with Apple ID
3. Drag and drop IPA file
4. Click "Deliver"

### Step 2: Wait for Processing

- Processing typically takes 5-30 minutes
- You'll receive email when complete
- Build will appear in "Build" section

### Step 3: Select Build

1. In version page, scroll to "Build" section
2. Click "Select a build before you submit your app"
3. Choose your uploaded build
4. Click "Done"

### Step 4: Export Compliance

**Does your app use encryption?**
```
☑️ Yes
```

**Does your app qualify for exemption?**
```
☑️ Yes - Uses standard encryption (HTTPS)
```

---

## Screenshots and Media

### Required Screenshot Sizes

**6.7" Display (iPhone 14 Pro Max, 15 Pro Max):**
- Resolution: 1290 x 2796 pixels
- Required: 3-10 screenshots

**6.5" Display (iPhone 11 Pro Max, XS Max):**
- Resolution: 1242 x 2688 pixels
- Required: 3-10 screenshots

**5.5" Display (iPhone 8 Plus):**
- Resolution: 1242 x 2208 pixels
- Optional but recommended

**iPad Pro (12.9", 3rd gen):**
- Resolution: 2048 x 2732 pixels
- Required if supporting iPad

### Screenshot Guidelines

1. **Show actual app UI**
2. **No device frames** (Apple adds them)
3. **High quality** (PNG or JPEG)
4. **Localized** (if supporting multiple languages)
5. **Consistent order** across all sizes

### App Preview Video (Optional)

- Maximum 30 seconds
- Same sizes as screenshots
- Show app in action
- No music with copyright

### Upload Screenshots

1. Scroll to "App Preview and Screenshots"
2. Select device size
3. Drag and drop images
4. Reorder as needed
5. Repeat for all required sizes

---

## App Review Information

### Step 1: Contact Information

**First Name:**
```
Your First Name
```

**Last Name:**
```
Your Last Name
```

**Phone Number:**
```
+1 (555) 123-4567
```

**Email:**
```
support@expensetracker.app
```

### Step 2: Demo Account (If Required)

**Sign-in Required:**
```
☐ No - App works without account
```

If Yes:
```
Username: demo@expensetracker.app
Password: DemoPass123!
```

### Step 3: Notes

```
Thank you for reviewing ExpenseTracker!

Key Features to Test:
1. Add new expense (tap + button on dashboard)
2. View analytics (Analytics tab)
3. Set budget (Budget tab)
4. Scan receipt (Camera icon in add expense)
5. Enable biometric auth (Settings → Security)

All features work without internet connection.
No special configuration needed.

Please contact us if you have any questions.
```

### Step 4: Attachments (If Needed)

- Upload demo video if features need explanation
- Add screenshots of special features

---

## TestFlight Setup

### Step 1: Navigate to TestFlight

1. Click "TestFlight" tab at top
2. Your build should appear automatically

### Step 2: Test Information

**What to Test:**
```
Please test the following:
• Expense tracking functionality
• Budget alerts
• Receipt scanning
• Data export
• Biometric authentication
• Overall app performance
```

**Feedback Email:**
```
beta@expensetracker.app
```

### Step 3: Internal Testing

1. Click "Internal Testing"
2. Add internal testers (up to 100)
3. Click "Start Testing"

### Step 4: External Testing (Optional)

1. Click "External Testing"
2. Create test group
3. Add external testers (up to 10,000)
4. Submit for Beta App Review
5. Wait for approval (usually 24-48 hours)

---

## Submit for Review

### Step 1: Final Checklist

- [ ] All required fields completed
- [ ] Build selected
- [ ] Screenshots uploaded for all sizes
- [ ] Privacy policy accessible
- [ ] App review information provided
- [ ] Export compliance answered
- [ ] Age rating appropriate
- [ ] Description and keywords optimized

### Step 2: Submit

1. Click "Add for Review" (top right)
2. Review submission summary
3. Click "Submit to App Review"

### Step 3: Wait for Review

**Timeline:**
- Initial review: 24-48 hours typically
- Can take up to 7 days
- Expedited review available for urgent issues

**Status Updates:**
- Waiting for Review
- In Review
- Pending Developer Release
- Ready for Sale
- Rejected (if issues found)

### Step 4: Monitor Status

- Check App Store Connect regularly
- Respond quickly to any questions
- Fix issues if rejected

---

## Troubleshooting

### Build Not Appearing

**Solution:**
- Wait 30 minutes after upload
- Check email for processing errors
- Verify bundle ID matches
- Re-upload if necessary

### Missing Required Screenshots

**Solution:**
- Provide at least 6.7" and 5.5" screenshots
- Use screenshot resizing tools if needed
- Ensure correct dimensions

### Privacy Policy Not Accessible

**Solution:**
- Verify URL is publicly accessible
- Check for HTTPS (required)
- Test in incognito/private browser

### Export Compliance Issues

**Solution:**
- Most apps qualify for exemption
- Standard HTTPS encryption is exempt
- Contact Apple if unsure

### Rejection: Guideline 2.1 - Performance

**Solution:**
- Fix crashes reported by Apple
- Test on multiple devices
- Ensure app doesn't freeze

### Rejection: Guideline 4.0 - Design

**Solution:**
- Follow Human Interface Guidelines
- Ensure consistent UI
- Fix any placeholder content

---

## Post-Submission

### If Approved

1. **Release Options:**
   - Automatic release
   - Manual release
   - Scheduled release

2. **Monitor:**
   - Crash reports
   - User reviews
   - Download metrics

3. **Respond:**
   - Reply to user reviews
   - Fix reported issues
   - Plan updates

### If Rejected

1. **Read rejection reason carefully**
2. **Fix all issues mentioned**
3. **Test thoroughly**
4. **Respond in Resolution Center**
5. **Resubmit**

---

## Resources

- App Store Connect: https://appstoreconnect.apple.com/
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- App Store Marketing: https://developer.apple.com/app-store/marketing/guidelines/

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0