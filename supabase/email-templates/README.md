# Supabase Email Templates

Professional, branded email templates for Your Coaching Hub authentication emails.

## 📧 Available Templates

1. **password-reset.html** - Password reset request email
2. **email-confirmation.html** - New user email verification
3. **magic-link.html** - Passwordless login link
4. **invite-user.html** - User invitation to platform

## 🎨 Design Features

- **Consistent Branding**: Purple gradient header matching Your Coaching Hub theme
- **Professional Logo**: Uses hosted logo from Supabase storage
- **Responsive Design**: Works on all email clients and devices
- **Clear CTAs**: Prominent action buttons with fallback text links
- **Security Notes**: Important information about link expiration
- **Contact Information**: Support email for help

## 🚀 How to Implement in Supabase

### Step 1: Access Email Templates in Supabase Dashboard

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project: `coaching-resource-hub`
3. Navigate to **Authentication** → **Email Templates**

### Step 2: Configure Each Template

#### Password Reset Email
1. Select **Reset Password** template
2. Copy the entire content from `password-reset.html`
3. Paste into the HTML editor
4. The template uses `{{ .ConfirmationURL }}` which Supabase automatically replaces

#### Confirm Email
1. Select **Confirm signup** template
2. Copy the entire content from `email-confirmation.html`
3. Paste into the HTML editor
4. The welcome message and features preview will show for new signups

#### Magic Link
1. Select **Magic Link** template
2. Copy the entire content from `magic-link.html`
3. Paste into the HTML editor
4. Used for passwordless authentication

#### Invite User
1. Select **Invite user** template
2. Copy the entire content from `invite-user.html`
3. Paste into the HTML editor
4. Supports beta user flag: `{{ if .Data.beta_user }}`

### Step 3: Configure Email Settings

In **Authentication** → **Email Configuration**:

```
From Name: Your Coaching Hub
From Email: noreply@yourcoachinghub.co.uk (or your configured email)
Reply-To: hello@yourcoachinghub.co.uk
```

### Step 4: Update Subject Lines

Recommended subject lines for each template:

- **Password Reset**: "Reset your password for Your Coaching Hub"
- **Email Confirmation**: "Welcome! Please confirm your email"
- **Magic Link**: "Your login link for Your Coaching Hub"
- **Invite User**: "You're invited to join Your Coaching Hub!"

## 📝 Template Variables

Supabase provides these variables that are used in templates:

- `{{ .ConfirmationURL }}` - The action URL (reset, confirm, login)
- `{{ .Email }}` - User's email address
- `{{ .Token }}` - Authentication token
- `{{ .TokenHash }}` - Hashed token
- `{{ .SiteURL }}` - Your site URL
- `{{ .Data }}` - Custom user metadata (e.g., beta_user flag)

## 🎯 Customization Tips

### Logo Update
If you need to change the logo, update this URL in all templates:
```html
https://hfmpacbmbyvnupzgorek.supabase.co/storage/v1/object/public/coaching-downloads/assets/full-logo.png
```

### Color Scheme
Main gradient used throughout:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Support Email
Update support email if needed:
```html
hello@yourcoachinghub.co.uk
```

## 🧪 Testing Templates

1. **Test Mode**: Enable test mode in Supabase to prevent actual emails
2. **Preview**: Use Supabase's preview feature to see rendered templates
3. **Send Test**: Send test emails to verify formatting
4. **Check Clients**: Test in various email clients (Gmail, Outlook, Apple Mail)

## 📱 Mobile Optimization

All templates include:
- Responsive table layouts
- Mobile-friendly button sizes (minimum 44px touch targets)
- Readable font sizes (minimum 14px for body text)
- Proper viewport meta tags

## 🔒 Security Considerations

- Link expiration times are clearly stated
- Security notes for unintended recipients
- Clear "ignore this email" instructions
- No sensitive information in email content

## 📊 Email Client Compatibility

Tested and optimized for:
- Gmail (Web, iOS, Android)
- Outlook (2016+, Web, Mobile)
- Apple Mail (macOS, iOS)
- Yahoo Mail
- Samsung Mail
- Thunderbird

## 🛠️ Maintenance

To update templates:
1. Edit the HTML files in this directory
2. Test changes locally using an HTML preview
3. Copy updated content to Supabase dashboard
4. Send test emails to verify changes

## 📞 Support

For issues with email templates:
- Contact: hello@yourcoachinghub.co.uk
- Documentation: [Supabase Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)