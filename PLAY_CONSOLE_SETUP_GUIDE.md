# Google Play Console Configuration Guide

## Complete Step-by-Step Guide to Setting Up Your App in Google Play Console

This guide walks you through the entire process of configuring your app in Google Play Console, from initial setup to production release.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Access Play Console](#access-play-console)
3. [Create New App](#create-new-app)
4. [Store Listing](#store-listing)
5. [App Content](#app-content)
6. [Pricing and Distribution](#pricing-and-distribution)
7. [Release Management](#release-management)
8. [Upload AAB](#upload-aab)
9. [Internal Testing](#internal-testing)
10. [Production Release](#production-release)
11. [Post-Launch](#post-launch)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- ✅ Google Play Developer Account ($25 one-time fee)
- ✅ Signed AAB file ready for upload
- ✅ App icon (512x512 PNG)
- ✅ Feature graphic (1024x500 PNG)
- ✅ Screenshots (minimum 2, maximum 8 per type)
- ✅ Privacy Policy URL (hosted)
- ✅ Valid payment method for developer account

---

## Access Play Console

### Step 1: Create Developer Account

1. Go to https://play.google.com/console/signup
2. Sign in with Google account
3. Accept Developer Distribution Agreement
4. Pay $25 registration fee
5. Complete account details:
   - Developer name: `ExpenseTracker`
   - Email address
   - Phone number
   - Website (optional)

### Step 2: Verify Identity

1. Complete identity verification (required)
2. Provide government-issued ID
3. Wait for verification (usually 24-48 hours)

### Step 3: Access Console

1. Go to https://play.google.com/console/
2. Sign in with your Google account

---

## Create New App

### Step 1: Create App

1. Click "Create app" button
2. Fill in basic information:

**App name:**
```
ExpenseTracker
```
- Maximum 50 characters
- Must be unique in Play Store

**Default language:**
```
English (United States) – en-US
```

**App or game:**
```
○ App
○ Game
```
Select: **App**

**Free or paid:**
```
○ Free
○ Paid
```
Select: **Free**

**Declarations:**
- ☑️ I declare that this app complies with Google Play's Developer Program Policies
- ☑️ I declare that this app complies with US export laws

3. Click "Create app"

---

## Store Listing

### Step 1: Navigate to Store Listing

1. In left sidebar: Dashboard → Store presence → Main store listing
2. Complete all required fields

### Step 2: App Details

**App name:**
```
ExpenseTracker
```

**Short description:**
```
Smart expense tracking and budget management made simple. Track spending, scan receipts, and achieve your financial goals.
```
- Maximum 80 characters
- Appears in search results
- Include key features and benefits

**Full description:**
```
ExpenseTracker is your personal finance companion that makes managing money simple and stress-free.

💰 SMART EXPENSE TRACKING
• Quickly log expenses and income
• Categorize transactions automatically
• Attach receipt photos with OCR scanning
• Tag expenses with location
• Add custom notes and descriptions
• Multiple currency support

📊 BUDGET MANAGEMENT
• Set budgets by category or overall
• Real-time spending alerts and notifications
• Visual progress indicators
• Monthly budget comparisons
• Smart spending insights and recommendations
• Budget rollover options

📈 POWERFUL ANALYTICS
• Interactive charts and graphs
• Spending trends analysis
• Category breakdowns and comparisons
• Monthly and yearly reports
• Export reports (PDF, CSV, Excel)
• Custom date range filtering

📸 RECEIPT MANAGEMENT
• Scan receipts with camera
• OCR text extraction
• Organize by category and date
• Cloud backup (optional)
• Quick search and filtering
• Attach multiple receipts per expense

🔒 SECURE & PRIVATE
• Biometric authentication (Fingerprint, Face unlock)
• AES-256 encryption for all data
• Local data storage - your data stays on your device
• No ads, no data selling
• GDPR & CCPA compliant
• Regular security updates

✨ BEAUTIFUL DESIGN
• Intuitive, modern Material Design interface
• Dark mode support
• Smooth animations and transitions
• Customizable themes and colors
• Accessibility features (TalkBack support)
• Tablet-optimized layouts

🎯 PERFECT FOR:
• Personal finance management
• Budget tracking and planning
• Expense reporting for work
• Financial goal setting
• Receipt organization
• Small business expense tracking

🌟 KEY FEATURES:
• Offline mode - works without internet
• Recurring expenses and income
• Multiple accounts support
• Data export and backup
• Reminders and notifications
• Widget support for quick entry
• Search and filter transactions
• Custom categories and tags

Download ExpenseTracker today and start your journey to financial freedom!

📧 Support: support@expensetracker.app
🌐 Website: https://expensetracker.app
📱 Follow us for tips and updates

---

PRIVACY & SECURITY
We take your privacy seriously. All financial data is encrypted and stored locally on your device. We never sell your data to third parties. Read our full privacy policy at: https://expensetra7629.builtwithrocket.new/privacy_policy.html

SUPPORT
Need help? Contact us at support@expensetracker.app or visit our Help Center in the app.
```
- Maximum 4,000 characters
- Use formatting (bullets, emojis)
- Highlight unique features
- Include keywords naturally
- Add support and privacy information

### Step 3: Graphics Assets

**App icon:**
- Size: 512 x 512 pixels
- Format: 32-bit PNG with alpha
- File: `assets/images/app_icon_primary_v1.png`

**Feature graphic:**
- Size: 1024 x 500 pixels
- Format: JPEG or 24-bit PNG (no alpha)
- File: `assets/images/play_store_feature_graphic.png`

**Phone screenshots:**
- Minimum 2, maximum 8
- JPEG or 24-bit PNG (no alpha)
- Minimum dimension: 320px
- Maximum dimension: 3840px
- Aspect ratio: 16:9 to 9:16

Required screenshots:
1. Dashboard/Home screen
2. Add expense screen
3. Analytics/Reports screen
4. Budget management screen
5. Receipt scanner screen

**7-inch tablet screenshots (Optional):**
- Same requirements as phone
- Optimized for tablet layout

**10-inch tablet screenshots (Optional):**
- Same requirements as phone
- Optimized for larger tablets

**Promotional video (Optional):**
```
https://www.youtube.com/watch?v=YOUR_VIDEO_ID
```
- YouTube URL
- 30 seconds to 2 minutes
- Shows app features

### Step 4: Categorization

**App category:**
```
Finance
```

**Tags (Optional):**
```
Budgeting, Personal Finance, Money Management
```
- Maximum 5 tags
- Helps users discover your app

### Step 5: Contact Details

**Email:**
```
support@expensetracker.app
```

**Phone (Optional):**
```
+1 (555) 123-4567
```

**Website:**
```
https://expensetracker.app
```

**Privacy policy URL:**
```
https://expensetra7629.builtwithrocket.new/privacy_policy.html
```
- Required for all apps
- Must be publicly accessible

### Step 6: Save

Click "Save" at the bottom of the page.

---

## App Content

### Step 1: Privacy Policy

1. Navigate to: Policy → App content → Privacy policy
2. Enter privacy policy URL:
```
https://expensetra7629.builtwithrocket.new/privacy_policy.html
```
3. Click "Save"

### Step 2: App Access

1. Navigate to: Policy → App content → App access
2. Select access type:
```
○ All functionality is available without special access
○ All or some functionality is restricted
```
Select: **All functionality is available without special access**

3. Click "Save"

### Step 3: Ads

1. Navigate to: Policy → App content → Ads
2. Answer question:
```
Does your app contain ads?
○ No
○ Yes
```
Select: **No**

3. Click "Save"

### Step 4: Content Rating

1. Navigate to: Policy → App content → Content rating
2. Click "Start questionnaire"
3. Enter email address for certificate
4. Select category: **Utility, Productivity, Communication, or Other**
5. Answer questionnaire:

**Violence:**
- Does your app depict realistic violence? **No**
- Does your app depict unrealistic or cartoon violence? **No**

**Sexual Content:**
- Does your app contain sexual content? **No**

**Language:**
- Does your app contain profanity? **No**

**Controlled Substances:**
- Does your app reference or depict alcohol, tobacco, or drugs? **No**

**Gambling:**
- Does your app contain simulated gambling? **No**
- Does your app allow users to gamble with real money? **No**

**User Interaction:**
- Can users interact with each other? **No**
- Can users share their location? **Yes** (optional location tagging)
- Can users share personal information? **No**

6. Submit questionnaire
7. Review rating (should be **Everyone** or **PEGI 3**)
8. Click "Apply rating"

### Step 5: Target Audience

1. Navigate to: Policy → App content → Target audience and content
2. Select target age groups:
```
☑️ Ages 18 and over
```

3. Is your app designed for children?
```
○ No
```

4. Click "Save"

### Step 6: News Apps

1. Navigate to: Policy → App content → News apps
2. Is this a news app?
```
○ No
```

3. Click "Save"

### Step 7: COVID-19 Contact Tracing

1. Navigate to: Policy → App content → COVID-19 contact tracing and status apps
2. Is this a contact tracing or status app?
```
○ No
```

3. Click "Save"

### Step 8: Data Safety

1. Navigate to: Policy → App content → Data safety
2. Click "Start"

**Data Collection:**
```
Does your app collect or share any of the required user data types?
○ Yes
```

**Data Types Collected:**

**Financial info:**
- ☑️ Purchase history
- ☑️ Other financial info (expense data)

**Personal info:**
- ☑️ Email address
- ☑️ Name (optional)

**Photos and videos:**
- ☑️ Photos (receipt images)

**Files and docs:**
- ☑️ Files and docs (exported reports)

**App activity:**
- ☑️ App interactions (analytics)

**Device or other IDs:**
- ☑️ Device or other IDs (crash reporting)

**For each data type, specify:**

**Is this data collected, shared, or both?**
```
○ Collected
```

**Is this data processed ephemerally?**
```
○ No
```

**Is this data required or optional?**
```
○ Required for core functionality
```

**Why is this data collected?**
- App functionality
- Analytics
- Personalization

**Data Security:**
- ☑️ Data is encrypted in transit
- ☑️ Data is encrypted at rest
- ☑️ Users can request data deletion

3. Preview data safety section
4. Click "Submit"

---

## Pricing and Distribution

### Step 1: Navigate to Pricing

1. In left sidebar: Release → Production → Countries/regions

### Step 2: Configure Pricing

**App pricing:**
```
○ Free
○ Paid
```
Select: **Free**

**In-app purchases:**
```
Does your app contain in-app purchases?
○ No
○ Yes
```
Select: **No** (or Yes if you have premium features)

### Step 3: Countries and Regions

```
☑️ Add all countries (available in 150+ countries)
```

Or select specific countries:
- United States
- United Kingdom
- Canada
- Australia
- European Union countries
- Others as needed

### Step 4: Distribution Settings

**Google Play for Education:**
```
○ No, my app is not designed for education
```

**Google Play Instant:**
```
○ No, don't publish an instant app
```

**Wear OS:**
```
○ No, my app doesn't have a Wear OS experience
```

**Android TV:**
```
○ No, my app doesn't have an Android TV experience
```

**Chrome OS:**
```
○ Yes, my app is optimized for Chrome OS (if applicable)
```

### Step 5: Save

Click "Save".

---

## Release Management

### Step 1: Navigate to Releases

1. In left sidebar: Release → Production
2. Or: Release → Internal testing (for testing first)

### Step 2: Create Release

1. Click "Create new release"
2. Google Play App Signing:
```
☑️ Let Google manage and protect your app signing key (recommended)
```

---

## Upload AAB

### Step 1: Upload App Bundle

1. In release page, click "Upload"
2. Select your AAB file:
```
build/app/outputs/bundle/release/app-release.aab
```
3. Wait for upload and processing

### Step 2: Review Warnings

Play Console may show warnings:
- **Unoptimized APK:** Normal for first upload
- **Missing translations:** Add if supporting multiple languages
- **Permissions:** Review and justify

### Step 3: Release Name

```
Version 1.0.0 - Initial Release
```

### Step 4: Release Notes

**What's new in this release:**
```
Welcome to ExpenseTracker!

✨ Features:
• Track expenses and income with ease
• Smart budget management with real-time alerts
• Receipt scanning with OCR technology
• Detailed analytics and spending insights
• Secure biometric authentication
• Beautiful, intuitive Material Design interface
• Export data in PDF, CSV, and Excel formats
• Dark mode support
• Offline mode - works without internet
• Multiple currency support

Start taking control of your finances today!

Questions or feedback? Contact us at support@expensetracker.app
```
- Maximum 500 characters per language
- Use bullet points
- Highlight key features
- Include support contact

---

## Internal Testing

### Step 1: Create Internal Testing Release

1. Navigate to: Release → Internal testing
2. Click "Create new release"
3. Upload AAB
4. Add release notes
5. Click "Save"

### Step 2: Create Tester List

1. Click "Testers" tab
2. Create email list:
```
Internal Testers
```
3. Add tester emails (up to 100)
4. Click "Save"

### Step 3: Start Testing

1. Review release
2. Click "Start rollout to Internal testing"
3. Confirm

### Step 4: Share Test Link

Testers will receive:
- Email invitation
- Opt-in URL
- Instructions to join

Or share direct link:
```
https://play.google.com/apps/internaltest/YOUR_PACKAGE_NAME
```

---

## Production Release

### Step 1: Navigate to Production

1. In left sidebar: Release → Production
2. Click "Create new release"

### Step 2: Upload AAB

1. Upload your signed AAB
2. Or promote from Internal testing

### Step 3: Release Details

**Release name:**
```
1.0.0
```

**Release notes:**
(Same as internal testing)

### Step 4: Rollout Percentage

**Staged rollout (Optional):**
```
○ 100% - Full rollout
○ Custom percentage (e.g., 20%, 50%)
```

Recommended for first release: **20%**
- Monitor for issues
- Increase gradually
- Reach 100% after stability confirmed

### Step 5: Review Release

1. Review all information
2. Check for errors or warnings
3. Ensure all required sections complete

### Step 6: Submit for Review

1. Click "Review release"
2. Review summary
3. Click "Start rollout to Production"
4. Confirm

### Step 7: Wait for Review

**Timeline:**
- Initial review: Few hours to 7 days
- Average: 1-3 days
- Can be expedited for critical updates

**Status:**
- Pending publication
- Under review
- Approved
- Rejected (if issues found)

---

## Post-Launch

### Step 1: Monitor Release

**Dashboard metrics:**
- Installs
- Uninstalls
- Crashes
- ANRs (App Not Responding)
- User ratings
- Reviews

### Step 2: Respond to Reviews

1. Navigate to: Grow → User reviews
2. Read user feedback
3. Respond to reviews (especially negative ones)
4. Address common issues in updates

### Step 3: Track Performance

**Key metrics:**
- Install conversion rate
- Retention rate
- Crash-free users
- Average rating
- Store listing visitors

### Step 4: Plan Updates

1. Fix reported bugs
2. Add requested features
3. Improve based on feedback
4. Release regular updates

---

## Troubleshooting

### AAB Upload Failed

**Solution:**
- Verify AAB is properly signed
- Check version code is incremented
- Ensure package name matches
- Try re-uploading

### Missing Store Listing Information

**Solution:**
- Complete all required fields
- Add minimum 2 screenshots
- Provide privacy policy URL
- Fill in contact details

### Content Rating Not Completed

**Solution:**
- Complete content rating questionnaire
- Submit and apply rating
- Wait for certificate

### Data Safety Section Incomplete

**Solution:**
- Declare all data collection
- Specify data usage purposes
- Confirm security practices
- Submit section

### Rejected: Violation of Developer Policy

**Solution:**
- Read rejection reason carefully
- Review Developer Program Policies
- Fix all mentioned issues
- Appeal if you believe it's an error

### Rejected: Broken Functionality

**Solution:**
- Test app thoroughly
- Fix crashes and bugs
- Ensure all features work
- Resubmit

---

## Resources

- Play Console: https://play.google.com/console/
- Developer Policies: https://play.google.com/about/developer-content-policy/
- Launch Checklist: https://developer.android.com/distribute/best-practices/launch/launch-checklist
- Material Design: https://material.io/design

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0