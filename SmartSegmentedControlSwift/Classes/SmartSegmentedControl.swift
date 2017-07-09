//
//  SmartSegmentedControl.swift
//  SmartSegmentedControlSwift
//
//  Created by Ievgen Shevtsov on 5/28/17.
//
//

import Foundation
import UIKit

public class SmartSegmentedControl: UISegmentedControl {
    
    // MARK: properties
    @IBInspectable public var smartAdjustment: Bool = false
    @IBInspectable public var fixNativeProportionalSizing: Bool = false

    fileprivate var segmentsIndexesWithExplicitWidthSet:Set<Int> = Set()

    
    // MARK: initialization overrides
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    private func commonInit() {
        for i in 0..<numberOfSegments {
            if widthForSegment(at: i) > 0 {
                segmentsIndexesWithExplicitWidthSet.insert(i)
            }
        }
    }
    
    
    // MARK: overrides to inject new logic
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if fixNativeProportionalSizing || smartAdjustment {
            var titles = widthsForSegmentsTitles()
            var width = self.frame.size.width

            let dividerWidth: CGFloat
            if let dividerImage = dividerImage(forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default) {
                dividerWidth = dividerImage.size.width
            }
            else {
                dividerWidth = 1.0
            }
            width -= dividerWidth*CGFloat(numberOfSegments-1)
            
            for i in segmentsIndexesWithExplicitWidthSet.sorted(by:>) {
                if (i<titles.count) {
                    width -= widthForSegment(at: i)
                    titles.remove(at: i)
                }
            }
            

            if titles.count > 0 {
                var widths: Array<CGFloat>
                if smartAdjustment {
                    widths = smartWidth(withTitlesWidths: titles, inTotalWidthAvailable: width)
                }
                else {
                    widths = proportionalWidths(withTitlesWidths: titles, inTotalWidthAvailable: width)
                }
                
                for i in segmentsIndexesWithExplicitWidthSet {
                    widths.insert(widthForSegment(at: i), at: i)
                }
                
                for i in 0..<widths.count {
                    super.setWidth(widths[i], forSegmentAt: i)
                }
            }
        }
        else {
            for i in 0..<numberOfSegments {
                if !segmentsIndexesWithExplicitWidthSet.contains(i) {
                    super.setWidth(0.0, forSegmentAt: i)
                }
            }
        }
    }
    
    public override func removeAllSegments() {
        segmentsIndexesWithExplicitWidthSet.removeAll()
        super.removeAllSegments()
    }
    
    public override func removeSegment(at segment: Int, animated: Bool) {
        segmentsIndexesWithExplicitWidthSet.remove(segment)
        var newSet = Set<Int>()
        for i in segmentsIndexesWithExplicitWidthSet {
            if i>segment {
                newSet.insert(i-1)
            }
            else {
                newSet.insert(i)
            }
        }
        segmentsIndexesWithExplicitWidthSet = newSet
        
        super.removeSegment(at: segment, animated: animated)
    }
    
    public override func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        var newSet = Set<Int>()
        for i in segmentsIndexesWithExplicitWidthSet {
            if i>=segment {
                newSet.insert(i+1)
            }
            else {
                newSet.insert(i)
            }
        }
        segmentsIndexesWithExplicitWidthSet = newSet

        super.insertSegment(withTitle: title, at: segment, animated: animated)
    }
    
    public override func setWidth(_ width: CGFloat, forSegmentAt segment: Int) {
        if width>0 {
            segmentsIndexesWithExplicitWidthSet.insert(segment)
        }
        else {
            segmentsIndexesWithExplicitWidthSet.remove(segment)
        }
        
        super.setWidth(width, forSegmentAt: segment)
    }
    
    
    
    
}

// MARK: calculations
private extension SmartSegmentedControl {
    
    func widthsForSegmentsTitles() -> Array<CGFloat> {
        let attributes: [String : Any]
        
        if let attr = titleTextAttributes(for: .normal) {
            attributes = attr as! [String : Any]
        }
        else {
            attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        }
        
        var widths = Array<CGFloat>()
        
        for i in 0..<numberOfSegments {
            let width: CGFloat
            if let text = titleForSegment(at: i) {
                width = text.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: self.frame.size.height), options: NSStringDrawingOptions(rawValue: 0), attributes: attributes, context: nil).width + 5.0
            }
            else {
                width = 5.0
            }
            
            widths.append(width)
        }
        
        return widths
    }
    
    func proportionalWidths(withTitlesWidths titles:Array<CGFloat>, inTotalWidthAvailable widthAvailable:CGFloat) -> Array<CGFloat> {
        var requiredWidth = CGFloat(0)
        for title in titles {
            requiredWidth += title
        }
        
        let ratio = widthAvailable/requiredWidth
        
        var widths = Array<CGFloat>()
        var actualLength = CGFloat(0)
        for title in titles {
            let width = floor(title*ratio)
            widths.append(width)
            actualLength += width
        }
        
        if widths.count > 0 {
            widths.append(widths.popLast()!+widthAvailable-actualLength)  //compensate rounding error
        }
        
        return widths
    }
    
    func smartWidth(withTitlesWidths titles:Array<CGFloat>, inTotalWidthAvailable widthAvailable:CGFloat) -> Array<CGFloat> {
        let equalWidth = floor(widthAvailable / CGFloat(titles.count))
        if titles.max()!<equalWidth {
            var widths = Array(repeating: equalWidth, count: titles.count)  //we can fit with simply equal segments
            widths.append(widths.popLast()! + widthAvailable - equalWidth*CGFloat(titles.count))
            return widths
        }

        
        var requiredWidth = CGFloat(0)
        for title in titles {
            requiredWidth += title
        }

        if requiredWidth >= widthAvailable {
            return proportionalWidths(withTitlesWidths:titles, inTotalWidthAvailable:widthAvailable)  //there is no way to fit all segments in width, so just adjusting segments proportionaly to content
        }
        
        //assume titles with width > equal width as adjusted on current step, all the others go to next iteration
        var titlesLeftToAdjust = Array<CGFloat>()
        var widthAdjusted = CGFloat(0)
        var titlesIndexesAdjusted = Array<Int>()
        
        for i in 0..<titles.count {
            let width = titles[i]
            if (width>equalWidth) {
                widthAdjusted += width
                titlesIndexesAdjusted.append(i)
            }
            else {
                titlesLeftToAdjust.append(width)
            }
        }
        
        var adjustedOnNextStep = titlesLeftToAdjust.count>0 ? smartWidth(withTitlesWidths: titlesLeftToAdjust, inTotalWidthAvailable: widthAvailable-widthAdjusted) : []
        
        for index in titlesIndexesAdjusted {
            adjustedOnNextStep.insert(titles[index], at: index)
        }
        
        return adjustedOnNextStep
    }
}

