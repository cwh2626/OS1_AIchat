//
//  CustomTableViewCell.swift
//  chat_AI
//
//  Created by 조웅희 on 2023/05/02.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    weak var delegate: CustomTableViewCellDelegate?
    
    // 글자 수 제한을 설정합니다.
    private let characterLimit = 500
    
    // 글자 수 제한 라벨
    let characterLimitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        label.textColor = UIColor(red: 238/255.0, green: 104/255.0, blue: 31/255.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .tertiaryBackgroundColor
        textView.textColor = .secondaryBackgroundColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        contentView.addSubview(textView)
        contentView.addSubview(characterLimitLabel)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            characterLimitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            characterLimitLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
        
        // textView의 delegate를 설정합니다.
        textView.delegate = self
    }
        
    func characterLimitLabelInit(textRange: Int){
        // 현재 텍스트의 길이를 라벨에 표시합니다.
        characterLimitLabel.text = "\(textRange)/\(characterLimit)"
    }
}

extension CustomTableViewCell: UITextViewDelegate {
    
    // UITextViewDelegate 메서드입니다. 텍스트 뷰의 텍스트가 변경될 때마다 호출됩니다.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // 텍스트 뷰의 현재 텍스트와 새로 입력되는 텍스트를 결합합니다.
        let currentText = textView.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
        print(#function,"현재 문자열: \(currentText), 합쳐진 문자열: \(prospectiveText), 문자열 길이: \(prospectiveText.count), 입력되어진 문자열\(text), range.location: \(range.location), range.length: \(range.length)")
    
        // replacingCharacters 로는 한글의 자음과 모음이 기대값이 나오지않기에 현재 한글의 제한 방법을
        // textViewDidChange함수에서 제한길이를 초과할경우 길이를 넘어간 만큼 자르기로 했다
        // 그런데 버그현상 발견 제한길에 다다랐을떄 마지막 텍스트는 수정이 되지만 백스페이스로 삭제시에
        // 수정전의 텍스트가 text에 스택에 쌓여있던것처럼 나타나서 삭제되는 현상을 발견
        // 그래서 해당 안건의 정확한 원인은 발견못했지만 현재위치의 함수에서 발생할것으로 추측
        // 해결하기위해 현재 위치의 함수에서
        // 입력된 값이 백스페이스이면서, 최대길이의 글이며, 입력바가 마지막일경우
        // 수동으로 text의 마지막값을 제거 하며 return값으 false로 입력된 백스페이스 기능을 못하게 막음으로써 현재 문제 해결
        // text.count == 0 :가 0 인경우는 즉 공백 백스페이스 경우 이다 코드내에서 직접적으로 text = "" 으로 하지않는 이상 현재까지는 백스페이스 이외의 경우를 발견하지 못했다
        // range.location + 1 >= characterLimit : 플러스 1을 한 이유는 입력되고 난뒤의 위치를 표시하기에 제한길에 맞추기 위한값 (백스페이스 위치 맨뒤)
        print(currentText.count, characterLimit, text.count)
        if text.count == 0 && currentText.count >= characterLimit && range.location + 1 >= characterLimit {
            textView.text.removeLast()
            characterLimitLabel.text = "\(textView.text.count)/\(characterLimit)"
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        // 텍스트 뷰의 현재 텍스트를 가져옵니다.
        let currentText = textView.text ?? ""
        
        // 현재 텍스트의 길이를 계산합니다.
        var length = currentText.count
        
        // 길이가 제한을 초과하면 텍스트 변경을 취소합니다.
        if length > characterLimit {

            // 텍스트를 제한 길이만큼 잘라냅니다.
            textView.text = String(currentText.prefix(characterLimit))
            
            // 잘라낸 텍스트의 길이를 재계산
            length = textView.text.count
        }
        
        // 길이를 라벨에 표시합니다.
        characterLimitLabel.text = "\(length)/\(characterLimit)"
        
        delegate?.textViewDidChange(text: textView.text, cell: self)
    }
}

protocol CustomTableViewCellDelegate: AnyObject {
    func textViewDidChange(text: String, cell: CustomTableViewCell)
}
