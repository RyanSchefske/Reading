//
//  PaywallView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var offerings: Offering?
    @State private var selectedPackage: Package?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.readerAccent.opacity(0.1),
                    Color.readerBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    header
                    featuresSection
                    pricingSection
                    ctaButton
                    restoreButton
                    disclaimerText
                }
                .padding()
            }
        }
        .overlay {
            if isLoading {
                loadingOverlay
            }
        }
        .task {
            await fetchOfferings()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Components

    private var header: some View {
        VStack(spacing: 16) {
            // Close button
            HStack {
                Spacer()
                Button {
                    HapticManager.shared.light()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.readerAccent, Color.readerAccent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }

            // Title
            VStack(spacing: 8) {
                Text("Upgrade to Pro")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text("Unlock all premium features")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What You Get")
                .font(.title2.bold())
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                ForEach(SubscriptionTier.pro.features) { feature in
                    FeatureRow(feature: feature)
                }
            }
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 16) {
            if let offering = offerings {
                // Monthly package
                if let monthlyPackage = offering.monthly {
                    packageCard(monthlyPackage, isFeatured: false)
                }

                // Annual package (featured)
                if let annualPackage = offering.annual {
                    packageCard(annualPackage, isFeatured: true)
                }

                // Lifetime package
                if let lifetimePackage = offering.lifetime {
                    packageCard(lifetimePackage, isFeatured: false)
                }
            } else {
                ProgressView()
                    .frame(height: 100)
            }
        }
    }

    private func packageCard(_ package: Package, isFeatured: Bool) -> some View {
        Button {
            HapticManager.shared.light()
            selectedPackage = package
        } label: {
            VStack(spacing: 12) {
                // Badge
                if isFeatured {
                    Text("BEST VALUE")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }

                // Title and price
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.storeProduct.localizedTitle)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let introOffer = package.storeProduct.introductoryDiscount {
                            Text("\(introOffer.subscriptionPeriod.periodTitle) free trial")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title3.bold())
                            .foregroundColor(.primary)

                        if package.packageType == .annual {
                            Text("Save 33%")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }

                // Checkmark
                if selectedPackage?.identifier == package.identifier {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                selectedPackage?.identifier == package.identifier
                                    ? Color.green
                                    : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var ctaButton: some View {
        Button {
            Task {
                await purchaseSelected()
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(ctaButtonText)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.readerAccent, Color.readerAccent.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(
                color: Color.readerAccent.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(selectedPackage == nil || isLoading)
        .opacity(selectedPackage == nil ? 0.6 : 1.0)
    }

    private var ctaButtonText: String {
        guard let package = selectedPackage else {
            return "Select a plan"
        }

        if package.storeProduct.introductoryDiscount != nil {
            return "Start Free Trial"
        } else {
            return "Subscribe Now"
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .underline()
        }
        .disabled(isLoading)
    }

    private var disclaimerText: some View {
        Text("Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Processing...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
            )
        }
    }

    // MARK: - Methods

    private func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings.current

            // Auto-select annual package if available
            if let annual = offerings.current?.annual {
                selectedPackage = annual
            } else if let monthly = offerings.current?.monthly {
                selectedPackage = monthly
            }
        } catch {
            errorMessage = "Failed to load subscription options. Please try again."
            showError = true
        }
    }

    private func purchaseSelected() async {
        guard let package = selectedPackage else { return }

        isLoading = true

        do {
            try await subscriptionManager.purchase(package: package)
            dismiss()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func restorePurchases() async {
        isLoading = true

        do {
            try await subscriptionManager.restorePurchases()

            if subscriptionManager.isPro {
                dismiss()
            } else {
                errorMessage = "No previous purchases found."
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

// MARK: - Extensions

extension SubscriptionPeriod {
    var periodTitle: String {
        let unitString: String
        switch unit {
        case .day:
            unitString = value == 1 ? "day" : "days"
        case .week:
            unitString = value == 1 ? "week" : "weeks"
        case .month:
            unitString = value == 1 ? "month" : "months"
        case .year:
            unitString = value == 1 ? "year" : "years"
        @unknown default:
            unitString = "period"
        }
        return "\(value) \(unitString)"
    }
}

// MARK: - Previews

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
