//
//  RHoverButton.swift
//  HoverButton
//
//  Created by Ray on 2017/5/25.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

/// 顯示方式
enum ShowType: Int {
    case showTypeOfLine = 1
    case showTypeOfCircle
}
/// 直線顯示方式
enum LineShowDirection: Int {
    case lineShowDirectionLeft = 1
    case lineShowDirectionRight
    case lineShowDirectionUp
    case lineShowDirectionDown
}
/// 圓形顯示方式
enum CircleShowDirection: Int {
    case circleShowDirectionLeft = 1
    case circleShowDirectionRight
    case circleShowDirectionUp
    case circleShowDirectionDown
    case circleShowDirectionRightDown
    case circleShowDirectionRightUp
    case circleShowDirectionLeftUp
    case circleShowDirectionLeftDown
}

struct RHoverModel {
    /// 主按鈕名稱
    var mainBtnTitle: String = ""
    /// 主按鈕選擇後名稱
    var mainBtnSelectTitle: String = ""
    /// 主按鈕背景圖片
    var mainBtnImage: UIImage?
    /// 主按鈕選擇後背景主按鈕背景圖片
    var mainBtnSelectImage: UIImage?
    /// 主按鈕背景顏色
    var mainBtnColor: UIColor = UIColor.clear
    /// 主按鈕選擇後背景顏色
    var mainBtnSelectColor: UIColor = UIColor.clear
    /// 主按鈕是否為圓形
    var mainBtnCircle: Bool = true
    /// 主按鈕圓角角度
    var mainBtnFillet: CGFloat = 0
    /// 子按鈕名稱
    var subBtnTitles: [String] = []
    /// 子按鈕主要背景圖片
    var subBtnMainImage: UIImage?
    /// 子按鈕主要選擇後背景圖片
    var subBtnMainSelectImage: UIImage?
    /// 子按鈕背景圖片組
    var subBtnImages: [UIImage] = []
    /// 子按鈕選擇後背景圖片組
    var subBtnSelectImages: [UIImage] = []
    /// 子按鈕背景顏色
    var subBtnColor: UIColor = UIColor.clear
    /// 子按鈕選擇後背景顏色
    var subBtnSelectColor: UIColor = UIColor.clear
    /// 子按鈕背景顏色組
    var subBtnColors: [UIColor] = []
}

class RHoverButton: UIView {
    
    /// 能否被拖曳
    var canBeMove: Bool = true {
        didSet {
            guard self.canBeMove else {
                guard let pen = self.pan else {
                    return
                }
                self.removeGestureRecognizer(pen)
                self.pan = nil
                return
            }
            
        }
    }
    /// 是否黏邊邊
    var buttonStickyEdge: Bool = false
    
    /// 顯示類型
    var showType: ShowType = .showTypeOfCircle
    
    /// 直線顯示方向
    var lineShowDirection: LineShowDirection = .lineShowDirectionDown
    
    /// 圓形顯示方式
    var circleShowDirection: CircleShowDirection = .circleShowDirectionLeft
    
    /// 四散按鈕和主按鈕間的距離
    private var distanceMainSub: CGFloat = 0
    
    /// 是否添加彈簧效果
    var showWithSpring: Bool = false
    
    /// 子按鈕離邊多遠
    var subBorderSpace: CGFloat = 10
    
    /// model
    var hoverModel: RHoverModel = RHoverModel()
    
    private var topDistance: CGFloat = 0  /// 離上面的距離
    private var bottomDistance: CGFloat = 0 /// 離下面的距離
    private var pan: UIGestureRecognizer? /// 手勢
    private var buttonArray: [UIButton] = [] /// 按鈕
    private var fixLength: CGFloat = 70 /// 子按鈕離主按鈕的距離
    private var offsetPoint: CGFloat = 0 /// 差多少??
    private var addWindows: Bool = false
    
    private let MainBounds: CGRect = UIScreen.main.bounds
    
    private var coverBtn: UIButton!
    private var mainBtn: UIButton!
    
    private var subAction: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.distanceMainSub = frame.width + 30
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: UI
    private func setupLayout(_ addView: UIView?) {
        
        if self.canBeMove {
            self.pan = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
            self.addGestureRecognizer(self.pan!)
        }
        /// 遮蓋畫面的按鈕
        let coverRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let coverButton = UIButton(frame: coverRect)
        coverButton.backgroundColor = UIColor.clear
        coverButton.addTarget(self, action: #selector(clickCoverButton), for: .touchUpInside)
        
        if let superView = addView {
            superView.insertSubview(coverButton, belowSubview: self)
        } else {
            UIApplication.shared.keyWindow?.insertSubview(coverButton, belowSubview: self)
        }
        
        self.coverBtn = coverButton
        
        /// 主按鈕
        let mainButton = UIButton(frame: self.bounds)
        mainButton.backgroundColor = self.hoverModel.mainBtnColor
        mainButton.setTitle(self.hoverModel.mainBtnTitle, for: .normal)
        mainButton.setTitle(self.hoverModel.mainBtnSelectTitle, for: .selected)
        if let image = self.hoverModel.mainBtnImage, let selectImage = self.hoverModel.mainBtnSelectImage {
            mainButton.setBackgroundImage(image, for: .normal)
            mainButton.setBackgroundImage(selectImage, for: .selected)
        }
        mainButton.addTarget(self, action: #selector(clickBtn(_:)), for: .touchUpInside)
        mainButton.layer.cornerRadius = self.hoverModel.mainBtnCircle ? mainButton.bounds.height / 2 : self.hoverModel.mainBtnFillet
        mainButton.layer.masksToBounds = true
        self.addSubview(mainButton)
        self.mainBtn = mainButton
        
        var buttonNumber: Int = 0
        if self.hoverModel.subBtnTitles.count > 0 && self.hoverModel.subBtnImages.count > 0 {
            buttonNumber = min(self.hoverModel.subBtnTitles.count, self.hoverModel.subBtnImages.count)
        } else {
            buttonNumber = max(self.hoverModel.subBtnTitles.count, self.hoverModel.subBtnImages.count)
        }
        
        let tempArray: NSMutableArray = NSMutableArray(capacity: buttonNumber)
        for i in 0..<buttonNumber {
            let subButton = UIButton(frame: self.bounds)
            subButton.backgroundColor = self.hoverModel.subBtnColors.count > i ? self.hoverModel.subBtnColors[i] : self.hoverModel.subBtnColor
            subButton.setTitle(self.hoverModel.subBtnTitles.count > i ? self.hoverModel.subBtnTitles[i] : "", for: .normal)
            subButton.setBackgroundImage(self.hoverModel.subBtnImages.count > i ? self.hoverModel.subBtnImages[i] : nil, for: .normal)
            
            subButton.layer.cornerRadius = self.hoverModel.mainBtnCircle ? subButton.bounds.height / 2 : self.hoverModel.mainBtnFillet
            subButton.layer.masksToBounds = true
            subButton.tag = 1000 + i
            subButton.addTarget(self, action: #selector(subBtnClick(_:)), for: .touchUpInside)
            self.insertSubview(subButton, belowSubview: mainButton)
            tempArray.add(subButton)
        }
        
        self.buttonArray = tempArray.copy() as! [UIButton]
    }
    
    // MARK: 存在於何處
    /// 存在於一個View當中
    func showInView(_ view: UIView) {
        view.addSubview(self)
        self.setupLayout(view)
    }
    /// 存在於KeyWindow當中
    func show() {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(self)
            self.setupLayout(nil)
        } else {
            print("沒有KeyWindow")
        }
        
    }
    
    /// 子案鈕點擊事件
    func subButtonAction(action: ((Int) -> Void)?) {
        self.subAction = action
    }
    
    @objc private func subBtnClick(_ button: UIButton) {
        if let action = self.subAction {
            action(button.tag - 1000)
        }
        self.clickCoverButton()
    }
    
    @objc private func clickCoverButton() {
        guard self.mainBtn.isSelected else {
            return
        }
        self.clickBtn(self.mainBtn)
    }
    /// 主按鈕事件
    @objc private func clickBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            if let pan = self.pan {
                self.addGestureRecognizer(pan)
            }
            sender.backgroundColor = self.hoverModel.mainBtnColor
            
            self.coverBtn.frame.size = CGSize(width: 0, height: 0)
            self.hideCircleButton()
            
            return
        }
        
        if let pan = self.pan {
            self.removeGestureRecognizer(pan)
        }
        
        sender.backgroundColor = self.hoverModel.mainBtnSelectColor
        
        self.showType == .showTypeOfCircle ? self.showCircleButton() : self.showLineButton()
        guard let getView = self.superview else {
            return
        }
        self.coverBtn.frame = getView.frame

    }
    
    /// 圓弧顯示Button
    private func showCircleButton() {
        self.fixLength = 70
        self.offsetPoint = 0
        let averangel = self.calSpreadDis(startAngel: 0, totalAngel: .pi * 2)
        
        for i in 0..<self.buttonArray.count {
            let p = self.calSubItemOffsetPoint(average: averangel * CGFloat(i), offset: self.offsetPoint)
            self.buttonArray[i].frame.origin = CGPoint(x: 0, y: 0)
//            UIView.animate(withDuration: 0.5, animations: {
//                self.buttonArray[i].frame.origin = CGPoint(x: p.x, y: -p.y)
//            })
            UIView.animate(withDuration: 0.2, delay: 0.02 * Double(i), options: .curveEaseIn, animations: {
                self.buttonArray[i].frame.origin = CGPoint(x: p.x, y: -p.y)
            }, completion: nil)
        }
    }
    /// 圓弧收回
    private func hideCircleButton() {
        for i in 0..<self.buttonArray.count {
//            UIView.animate(withDuration: 0.2, animations: {
//                self.buttonArray[i].frame.origin = CGPoint(x: 0, y: 0)
//            })
            UIView.animate(withDuration: 0.2, delay: 0.02 * Double(i), options: .curveEaseIn, animations: {
                self.buttonArray[i].frame.origin = CGPoint(x: 0, y: 0)
            }, completion: nil)
        }
//        var index = self.buttonArray.count
//        while index > 0 {
//            index = index - 1
//            UIView.animate(withDuration: 0.2, delay: 0.02 * Double(index), options: .curveEaseIn, animations: {
//                self.buttonArray[index].frame.origin = CGPoint(x: 0, y: 0)
//            }, completion: nil)
//        }
    }
    
    /// 計算展開位置
    private func calSpreadDis(startAngel sAngel: CGFloat, totalAngel tAngel: CGFloat) -> CGFloat {
        let value = self.calculationEdge()
        let angel = value.1 / CGFloat(value.0 ? self.buttonArray.count - 1 : self.buttonArray.count)
        
        let r1: CGFloat = CGFloat(2 * 2.squareRoot() * 25)
        
        if angel * self.fixLength < r1 {
            self.fixLength = self.fixLength + 5
            self.offsetPoint = 0
            return self.calSpreadDis(startAngel: 0, totalAngel: .pi * 2)
        }
        
        return angel
    }
    
    /// button 是否在邊緣 for Circle
    private func calculationEdge() -> (Bool, CGFloat) {
        let cp: CGPoint = CGPoint(x: self.frame.origin.x + self.frame.size.width / 2, y: self.frame.origin.y + self.frame.size.height / 2)
        
        var value: (Bool, CGFloat) = (false, .pi * 2)
        
        let lmax: CGFloat = self.fixLength + 25 + self.subBorderSpace
        
        if cp.y < lmax {
            let a1 = acos((cp.y - lmax + self.fixLength) / self.fixLength)
            var at = a1
            var ac = a1 * 2
            
            if self.MainBounds.width - lmax < cp.x {
                let a2 = acos((self.MainBounds.width - cp.x - lmax + self.fixLength) / self.fixLength)
                at = (.pi / 2) + a2
                ac = (.pi / 2) + a1 + a2
            }
            if cp.x < lmax {
                let a2 = acos((cp.x - lmax + self.fixLength) / self.fixLength)
                ac = (.pi / 2) + a1 + a2
            }
            
            value.0 = true
            
            value.1 = value.1 - ac
            self.offsetPoint = self.offsetPoint + at
            return value
        }
        
        if self.MainBounds.height - lmax < cp.y {
            let a1 = acos((self.MainBounds.height - cp.y - lmax + self.fixLength) / self.fixLength)
            var at = .pi + a1
            var ac = a1 * 2
            
            if cp.x < lmax {
                let a2 = acos((cp.x - lmax + self.fixLength) / self.fixLength)
                at = (.pi / 2) * 3 + a2
                ac = (.pi / 2) + a1 + a2
            }
            if self.MainBounds.width - lmax < cp.x {
                let a2 = acos((self.MainBounds.width - cp.x - lmax + self.fixLength) / self.fixLength)
                ac = (.pi / 2) + a1 + a2
            }
            value.0 = true
            value.1 = value.1 - ac
            self.offsetPoint = self.offsetPoint + at
            return value
        }
        
        if cp.x < lmax {
            let a2 = acos((cp.x - lmax + self.fixLength) / self.fixLength)
            var ac = a2 * 2
            var at = (.pi / 2) * 3 + a2
            value.0 = true
            
            if cp.y < lmax {
                let a1 = acos((cp.y - lmax + self.fixLength) / self.fixLength)
                at = a1
                ac = .pi / 2 + a1 + a2
            }
            
            if self.MainBounds.height - lmax < cp.y {
                let a1 = acos((self.MainBounds.height - cp.y - lmax + self.fixLength) / self.fixLength)
                ac = .pi / 2 + a1 + a2
            }
            
            value.1 = value.1 - ac
            self.offsetPoint = self.offsetPoint + at
            return value
        }
        
        if self.MainBounds.width - lmax < cp.x {
            let a2 = acos((self.MainBounds.width - cp.x - lmax + self.fixLength) / self.fixLength)
            let at = (.pi / 2) + a2
            var ac = a2 * 2
            
            value.0 = true
            
            if self.MainBounds.height - lmax < cp.y {
                let a1 = acos((self.MainBounds.height - cp.y - lmax + self.fixLength) / self.fixLength)
                ac = .pi / 2 + a1 + a2
            }
            
            if cp.y < lmax {
                let a1 = acos((cp.y - lmax + self.fixLength) / self.fixLength)
                ac = .pi / 2 + a1 + a2
            }
            
            value.1 = value.1 - ac
            self.offsetPoint = self.offsetPoint + at
            return value
        }
        
        return value
    }
    
    /// 角度
    private func calSubItemOffsetPoint(average: CGFloat, offset: CGFloat) -> CGPoint {
        let a = average + offset
        var p = CGPoint.zero
        
        p.x = self.fixLength * sin(a)
        p.y = self.fixLength * cos(a)
        
        return p
    }
    
    /// 直線顯示Button
    private func showLineButton() {
        print("還沒寫XDDDDD")
    }
    
    /// 拖曳
    @objc private func panView(_ gesture: UIPanGestureRecognizer) {
        
        guard let getView = self.superview else {
            return
        }
        
        let point = gesture.location(in: getView)
        
        self.center = point
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            break
        case .ended:
            var rect = self.frame
            
            guard self.buttonStickyEdge else {
                break
            }
            
            if self.center.x > getView.bounds.width / 2 {
                rect.origin.x = getView.bounds.width - self.bounds.width
            } else {
                rect.origin.x = 0
            }
            
            if self.frame.origin.y < self.topDistance {
                rect.origin.y = self.topDistance
            }
            
            if self.frame.origin.y > getView.bounds.height - self.bounds.height - self.bottomDistance {
                rect.origin.y = getView.bounds.height - self.bounds.height - self.bottomDistance
            }
            
            self.frame = rect
            
            break
        default:
            break
        }
    }
    
    /// 自動算出顯示方向
    private func automaticChangeShowDirection() {
        guard let getView = self.superview else {
            return
        }
        
        let halfWidth = getView.bounds.width / 2
        let halfHeight = getView.bounds.height / 2
        if self.center.x > halfWidth && self.center.y < halfHeight {
            self.circleShowDirection = self.center.y - self.topDistance > self.distanceMainSub ? .circleShowDirectionLeft : .circleShowDirectionLeftDown
            self.lineShowDirection = self.center.x < getView.bounds.height - self.center.y ? .lineShowDirectionDown : .lineShowDirectionLeft
        } else if self.center.x > halfWidth && self.center.y > halfHeight {
            self.circleShowDirection = getView.bounds.height - self.center.y - self.bottomDistance > self.distanceMainSub ? .circleShowDirectionLeft : .circleShowDirectionLeftUp
            self.lineShowDirection = self.center.x < self.center.y ? .lineShowDirectionUp : .lineShowDirectionLeft
        } else if self.center.x < halfWidth && self.center.y > halfHeight {
            self.circleShowDirection = getView.bounds.height - self.center.y - self.bottomDistance > self.distanceMainSub ? .circleShowDirectionRight : .circleShowDirectionRightUp
            self.lineShowDirection = getView.bounds.width - self.center.x < self.center.y ? .lineShowDirectionUp : .lineShowDirectionRight
        } else {
            self.circleShowDirection = self.center.y - self.topDistance > self.distanceMainSub ? .circleShowDirectionRight : .circleShowDirectionRightDown
            self.lineShowDirection = getView.bounds.width - self.center.x < getView.bounds.height - self.center.y ? .lineShowDirectionDown : .lineShowDirectionRight
        }
    }
    
    /// 超出部分點擊事件？？
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        guard view == nil else {
            return view
        }
        
        for v in self.subviews {
            let tmp = v.convert(point, from: self)
            if v.bounds.contains(tmp) {
                view = v
            }
        }
        return view
    }
}


