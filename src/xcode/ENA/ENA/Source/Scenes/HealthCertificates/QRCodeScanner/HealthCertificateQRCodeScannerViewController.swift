////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation
import HealthCertificateToolkit

class HealthCertificateQRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		didScanCertificate: @escaping (HealthCertifiedPerson, HealthCertificate) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.didScanCertificate = didScanCertificate
		self.dismiss = dismiss
		
		super.init(nibName: nil, bundle: nil)
		
		viewModel = HealthCertificateQRCodeScannerViewModel(
			healthCertificateService: healthCertificateService,
			onSuccess: { [weak self] healthCertifiedPerson, healthCertificate in
				AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
				self?.viewModel?.deactivateScanning()
				didScanCertificate(healthCertifiedPerson, healthCertificate)
			},
			onError: { error in
				switch error {
				case .cameraPermissionDenied:
					self.showCameraPermissionErrorAlert(error: error)
				default:
					self.showErrorAlert(error: error)
				}
			}
		)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupViewModel()
		setupNavigationBar()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updatePreviewMask()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		#if targetEnvironment(simulator) && DEBUG
			if !isUITesting {
				let healthCertificate = HealthCertificate.mock(base45: HealthCertificateMocks.lastBase45Mock)
				didScanCertificate(HealthCertifiedPerson(healthCertificates: [healthCertificate]), healthCertificate)
			}
		#endif
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel?.deactivateScanning()
	}

	// MARK: - Private

	private let focusView = QRScannerFocusView()
	private let didScanCertificate: (HealthCertifiedPerson, HealthCertificate) -> Void
	private let dismiss: () -> Void

	private var viewModel: HealthCertificateQRCodeScannerViewModel?
	private var previewLayer: AVCaptureVideoPreviewLayer! { didSet { updatePreviewMask() } }

	private func setupView() {
		navigationItem.title = AppStrings.HealthCertificate.QRScanner.title
		view.backgroundColor = .enaColor(for: .background)

		focusView.backdropOpacity = 0.2
		focusView.tintColor = .enaColor(for: .textContrast)
		focusView.translatesAutoresizingMaskIntoConstraints = false
		focusView.configure(cornerRadius: 8, borderWidth: 1)

		let instructionLabel = ENALabel()
		instructionLabel.style = .headline
		instructionLabel.numberOfLines = 0
		instructionLabel.textAlignment = .center
		instructionLabel.textColor = .enaColor(for: .textContrast)
		instructionLabel.font = .enaFont(for: .body)
		instructionLabel.text = AppStrings.HealthCertificate.QRScanner.instruction
		instructionLabel.layer.shadowColor = UIColor.enaColor(for: .textPrimary1Contrast).cgColor
		instructionLabel.layer.shadowOpacity = 1
		instructionLabel.layer.shadowRadius = 3
		instructionLabel.layer.shadowOffset = .init(width: 0, height: 0)
		instructionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(instructionLabel)
		view.addSubview(focusView)

		NSLayoutConstraint.activate(
			[
				instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				instructionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75, constant: 0),
				instructionLabel.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 32),

				focusView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
				focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				focusView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),
				focusView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
				focusView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: 0)
			]
		)
	}

	private func setupNavigationBar() {
		if #available(iOS 13.0, *) {
			navigationController?.overrideUserInterfaceStyle = .dark
		}
		navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		navigationController?.navigationBar.shadowImage = UIImage()
		if let image = UIImage.with(color: UIColor(white: 0, alpha: 0.5)) {
			navigationController?.navigationBar.setBackgroundImage(image, for: .default)
		}

		let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressDismiss))
		cancelItem.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
		navigationItem.leftBarButtonItem = cancelItem

		let flashButton = UIButton(type: .custom)
		flashButton.imageView?.contentMode = .center
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(named: "flash_disabled"), for: .normal)
		flashButton.setImage(UIImage(named: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash
		flashButton.accessibilityTraits = [.button]
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flashButton)
	}

	@objc
	private func didPressDismiss() {
		dismiss()
	}
	
	@objc
	private func didToggleFlash() {
		#if DEBUG
		if isUITesting {
			if LaunchArguments.healthCertificate.firstHealthCertificate.boolValue {
				viewModel?.didScan(base45: HealthCertificateMocks.lastBase45Mock)
			} else {
				viewModel?.didScan(base45: HealthCertificateMocks.firstBase45Mock)
			}

			return
		}
		#endif
		viewModel?.toggleFlash()
		updateToggleFlashAccessibility()
	}
	
	private func updateToggleFlashAccessibility() {
		guard let flashButton = navigationItem.rightBarButtonItem?.customView as? UIButton else {
			return
		}

		flashButton.accessibilityCustomActions?.removeAll()

		switch viewModel?.torchMode {
		case .notAvailable:
			flashButton.isEnabled = false
			flashButton.isSelected = false
			flashButton.accessibilityValue = nil
		case .lightOn:
			flashButton.isEnabled = true
			flashButton.isSelected = true
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOnValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityDisableAction, target: self, selector: #selector(didToggleFlash))]
		case .lightOff:
			flashButton.isEnabled = true
			flashButton.isSelected = false
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOffValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityEnableAction, target: self, selector: #selector(didToggleFlash))]
		case .none:
			break
		}
	}

	private func setupViewModel() {
		guard let captureSession = viewModel?.captureSession else {
			Log.debug("Failed to setup captureSession", log: .checkin)
			// Add dummy layer because the simulator doesn't support the camera
			previewLayer = AVCaptureVideoPreviewLayer()
			return
		}
		viewModel?.startCaptureSession()

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(previewLayer, at: 0)
	}

	private func showErrorAlert(error: Error) {
		viewModel?.deactivateScanning()

		var alertTitle = AppStrings.HealthCertificate.Error.title
		var errorMessage = error.localizedDescription + AppStrings.HealthCertificate.Error.faqDescription
		var faqAlertAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Error.faqButtonTitle,
			style: .default,
			handler: { [weak self] _ in
				if LinkHelper.open(urlString: AppStrings.Links.healthCertificateErrorFAQ) {
					self?.viewModel?.activateScanning()
				}
			}
		)

		// invalid signature error needs a different title, errorMessage and FAQ action
		if case let QRScannerError.other(wrappedError) = error,
		   case HealthCertificateServiceError.RegistrationError.invalidSignature = wrappedError {
			alertTitle = AppStrings.HealthCertificate.Error.invalidSignatureTitle
			errorMessage = wrappedError.localizedDescription
			faqAlertAction = UIAlertAction(
				title: AppStrings.HealthCertificate.Error.invalidSignatureFAQButtonTitle,
				style: .default,
				handler: { [weak self] _ in
					if LinkHelper.open(urlString: AppStrings.Links.invalidSignatureFAQ) {
						self?.viewModel?.activateScanning()
					}
				}
			)
		}

		let alert = UIAlertController(
			title: alertTitle,
			message: errorMessage,
			preferredStyle: .alert
		)
		alert.addAction(faqAlertAction)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel?.activateScanning()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

	private func showCameraPermissionErrorAlert(error: Error) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Error.title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .cancel,
				handler: { [weak self] _ in
					self?.dismiss()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

	private func updatePreviewMask() {

		guard let previewLayer = previewLayer else {
			Log.debug("No preview layer available")
			return
		}

		let backdropColor = UIColor(white: 0, alpha: 1 - max(0, min(focusView.backdropOpacity, 1)))
		let focusPath = UIBezierPath(roundedRect: focusView.frame, cornerRadius: focusView.layer.cornerRadius)

		let backdropPath = UIBezierPath(cgPath: focusPath.cgPath)
		backdropPath.append(UIBezierPath(rect: view.bounds))

		let backdropLayer = CAShapeLayer()
		backdropLayer.path = UIBezierPath(rect: view.bounds).cgPath
		backdropLayer.fillColor = backdropColor.cgColor

		let backdropLayerMask = CAShapeLayer()
		backdropLayerMask.fillRule = .evenOdd
		backdropLayerMask.path = backdropPath.cgPath
		backdropLayer.mask = backdropLayerMask

		let throughHoleLayer = CAShapeLayer()
		throughHoleLayer.path = UIBezierPath(cgPath: focusPath.cgPath).cgPath

		previewLayer.mask = CALayer()
		previewLayer.mask?.addSublayer(throughHoleLayer)
		previewLayer.mask?.addSublayer(backdropLayer)
	}
}
