//
//  ComfortLevelViewController.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit

class ComfortLevelViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "舒适  档位"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 5
        slider.value = 1
        slider.minimumTrackTintColor = .systemBlue
        slider.maximumTrackTintColor = .lightGray
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let scaleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var dots: [UIView] = []
    private let dotSize: CGFloat = 16
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSlider()
        setupScale()
        updateDots(for: 1)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(dotsStackView)
        view.addSubview(slider)
        view.addSubview(scaleStackView)
        
        // Create dots
        for i in 1...5 {
            let dot = createDot()
            dots.append(dot)
            dotsStackView.addArrangedSubview(dot)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dotsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            dotsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStackView.heightAnchor.constraint(equalToConstant: dotSize),
            
            slider.topAnchor.constraint(equalTo: dotsStackView.bottomAnchor, constant: 30),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            scaleStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20),
            scaleStackView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            scaleStackView.trailingAnchor.constraint(equalTo: slider.trailingAnchor)
        ])
    }
    
    private func configureSlider() {
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Set thumb image
        let thumbSize = CGSize(width: 30, height: 30)
        slider.setThumbImage(createThumbImage(size: thumbSize), for: .normal)
        
        // Create segmented appearance
        slider.setMinimumTrackImage(createTrackImage(color: .clear), for: .normal)
        slider.setMaximumTrackImage(createTrackImage(color: .clear), for: .normal)
    }
    
    private func setupScale() {
        for i in 1...5 {
            let label = UILabel()
            label.text = "\(i)"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            scaleStackView.addArrangedSubview(label)
        }
    }
    
    // MARK: - Helper Methods
    private func createDot() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = dotSize / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: dotSize).isActive = true
        view.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
        return view
    }
    
    private func createThumbImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func createTrackImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        }
    }
    
    private func updateDots(for value: Int) {
        dots.forEach { $0.backgroundColor = .lightGray }
        
        for i in 0..<value {
            if i < dots.count {
                dots[i].backgroundColor = .systemBlue
            }
        }
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.setValue(roundedValue, animated: false)
        updateDots(for: Int(roundedValue))
    }
}
