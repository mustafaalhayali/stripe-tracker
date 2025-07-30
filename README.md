# StripeTracker

A simple macOS menu bar application that displays your Stripe revenue metrics in real-time.

![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-FA7343?style=flat-square&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0066CC?style=flat-square&logo=swift&logoColor=white)

## Features

- **Real-time Revenue Tracking**: Monitor your Stripe revenue directly from the macOS menu bar
- **Multiple Time Periods**: View revenue for today, this week, and month-to-date (MTD)
- **Secure API Key Storage**: Your Stripe API key is securely stored in the macOS Keychain
- **Auto-refresh**: Automatically updates every 2 minutes
- **Clean Interface**: Minimal, non-intrusive design that stays out of your way
- **Instant Access**: Click the menu bar item to see detailed metrics

## Demo

https://github.com/mustafaalhayali/stripe-tracker/blob/main/striperev.mp4

_Watch StripeTracker in action - see how it displays real-time revenue metrics in your macOS menu bar_

## Installation

### From Source

1. Clone the repository:

   ```bash
   git clone https://github.com/mustafaalhayali/StripeTracker.git
   cd StripeTracker
   ```

2. Open `StripeTracker.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

### System Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for building from source)

## Setup

1. **Get your Stripe API Key**:

   - Log into your [Stripe Dashboard](https://dashboard.stripe.com/)
   - Go to Developers → API keys
   - Create and copy your "Secret key" (starts with `sk_live_` for live mode)

2. **Configure the App**:

   - Launch StripeTracker
   - Click the gear icon in the popover
   - Paste your Stripe API key
   - Click "Save"

3. **Enjoy**: Your revenue metrics will now appear in the menu bar!

## Security

- **API Key Storage**: Your Stripe API key is stored securely in the macOS Keychain, not in plain text
- **Network Security**: All API calls use HTTPS encryption
- **Sandboxed**: The app runs in a macOS sandbox for additional security
- **Minimal Permissions**: Only requests network access and keychain access

## Privacy

StripeTracker:

- Only communicates with Stripe's official API endpoints
- Does not collect, store, or transmit any personal data
- Does not use analytics or tracking
- Runs entirely on your local machine

## API Usage

The app fetches data from Stripe's `/charges` endpoint with the following parameters:

- Time-based filtering for today, week, and month
- Only successful, non-refunded charges are counted
- Pagination support for accounts with high transaction volumes

## Development

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **AppKit**: Native macOS menu bar integration
- **Foundation**: Secure keychain storage and networking
- **Combine**: Reactive data binding

### Project Structure

```
StripeTracker/
├── StripeTrackerApp.swift          # Main app entry point and menu bar logic
├── Assets.xcassets/                # App icons and visual assets
├── StripeTracker.entitlements      # App sandbox and security settings
└── Preview Content/                # SwiftUI preview assets
```

### Building

1. Clone the repository
2. Open in Xcode 14.0+
3. Select your development team in project settings
4. Build and run

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have feature requests, please open an issue on GitHub.

## Disclaimer

This app is not affiliated with Stripe, Inc. Stripe is a trademark of Stripe, Inc.
