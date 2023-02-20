//
//  BSWaveVisualizeView.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//
//  Based on: https://github.com/jyunderwood/WaveformView-iOS

import UIKit

let pi = Double.pi

@IBDesignable
public class BSWaveVisualizeView: UIView, BSSpeechWaveView {
    fileprivate(set) var _phase: CGFloat = 0.0
//    fileprivate(set) var _amplitude: CGFloat = 0.3
    
    private var _waveColor: UIColor = .black
    @IBInspectable public var waveColor: UIColor {
        get { _waveColor }
        set { _waveColor = newValue }
    }
    
    private var _numberOfWaves: Int = 6
    @IBInspectable public var numberOfWaves: Int {
        get { _numberOfWaves }
        set { _numberOfWaves = newValue }
    }
    
    private var _primaryWaveLineWidth: CGFloat = 3.0
    @IBInspectable public var primaryWaveLineWidth: CGFloat {
        get { _primaryWaveLineWidth }
        set { _primaryWaveLineWidth = newValue }
    }
    
    private var _secondaryWaveLineWidth: CGFloat = 0.3
    @IBInspectable public var secondaryWaveLineWidth: CGFloat {
        get { _secondaryWaveLineWidth }
        set { _secondaryWaveLineWidth = newValue }
    }
    
    private var _idleAmplitude: CGFloat = 0.01
    @IBInspectable public var idleAmplitude: CGFloat {
        get { _idleAmplitude }
        set { _idleAmplitude = newValue }
    }
    
    private var _frequency: CGFloat = 1.25
    @IBInspectable public var frequency: CGFloat {
        get { _frequency }
        set { _frequency = newValue }
    }
    
    private var _density: CGFloat = 5
    @IBInspectable public var density: CGFloat {
        get { _density }
        set { _density = newValue }
    }
    
    private var _phaseShift: CGFloat = -0.1
    @IBInspectable public var phaseShift: CGFloat {
        get { _phaseShift }
        set { _phaseShift = newValue}
    }
    
    private var _amplitude: CGFloat = 0.3
    @IBInspectable public var amplitude: CGFloat {
        get { _amplitude }
        set { _amplitude = newValue }
    }
    
    private var _startWithHidden: Bool = false
    @IBInspectable public var startWithHidden: Bool {
        get { _startWithHidden }
        set { _startWithHidden = newValue }
    }
    
    public func display(_ viewModel: BSSpeechWaveViewModel) {
        guard viewModel.duration > 0 else {
            self.alpha = viewModel.isShow ? 1 : 0
            return
        }
        
        UIView.animate(withDuration: viewModel.duration) {
            self.alpha = viewModel.isShow ? 1 : 0
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.alpha = startWithHidden ? 1 : 0
    }
    
    public func updateWithLevel(_ level: CGFloat) {
        _phase += phaseShift
        _amplitude = fmax(level, idleAmplitude)
        setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.clear(bounds)
        
        backgroundColor?.set()
        context.fill(rect)
        
        // Draw multiple sinus waves, with equal phases but altered
        // amplitudes, multiplied by a parable function.
        for waveNumber in 0...numberOfWaves {
            context.setLineWidth((waveNumber == 0 ? primaryWaveLineWidth : secondaryWaveLineWidth))
            
            let halfHeight = bounds.height / 2.0
            let width = bounds.width
            let mid = width / 2.0
            
            let maxAmplitude = halfHeight - 4.0 // 4 corresponds to twice the stroke width
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx,
            // which is used to alter the wave's amplitude.
            let progress: CGFloat = 1.0 - CGFloat(waveNumber) / CGFloat(numberOfWaves)
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            let multiplier: CGFloat = 1.0
            waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()
            
            var x: CGFloat = 0.0
            while x < width + density {
                // Use a parable to scale the sinus wave, that has its peak in the middle of the view.
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                let tempCasting: CGFloat = 2.0 * CGFloat(pi) * CGFloat(x / width) * frequency + _phase
                let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(tempCasting))) + halfHeight
                
                if x == 0 {
                    context.move(to: CGPoint(x: x, y: y))
                } else {
                    context.addLine(to: CGPoint(x: x, y: y))
                }
                
                x += density
            }
            
            context.strokePath()
        }
    }
}
