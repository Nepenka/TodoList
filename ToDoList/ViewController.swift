//
//  ViewController.swift
//  ToDoList
//
//  Created by 123 on 27.04.23.
//


import SnapKit
import UIKit

class ViewController: UIViewController {
    let buttonAction: UIButton = .init()
    let labelText: UILabel = .init()
    let welcomeText: UILabel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

 private func initialize() {
     view.backgroundColor = UIColor(red: 241/255, green: 238/255, blue: 228/255, alpha: 1)
     labelText.text = "Welcome!"
     labelText.font = UIFont.systemFont(ofSize: 26)
     view.addSubview(labelText)
     view.translatesAutoresizingMaskIntoConstraints = false
     labelText.snp.makeConstraints { maker in
         maker.left.equalToSuperview().inset(50)
         maker.top.equalToSuperview().inset(150)
         
     }
     welcomeText.textColor = .black
     welcomeText.font = UIFont.systemFont(ofSize: 25)
     welcomeText.text = "Всех приветствую! Я начинающий IOS-разработчик. И это мой перый пет-проект, в первую очередь я его создал для себя и конечно же для практического опыта в этой сфере. Спасибо за внимание!"
     welcomeText.numberOfLines = 0 //позволяет сделать так чтобы мой текст нормально выглядел на экране.
     view.addSubview(welcomeText)
     welcomeText.snp.makeConstraints { make in
         make.left.right.equalToSuperview().inset(50)
         make.top.equalTo(labelText).inset(70)
     }
     
     buttonAction.layer.cornerRadius = 30
     buttonAction.setBackgroundImage(UIImage(named: "arrow.up.circle"), for: .normal)
     buttonAction.layer.borderColor = UIColor.systemBlue.cgColor
     buttonAction.setTitleColor(.systemBlue, for: .normal)
     buttonAction.addTarget(self, action: #selector(secondButton), for: .touchUpInside)
     view.addSubview(buttonAction)
     buttonAction.snp.makeConstraints { make in
         make.left.right.equalToSuperview().inset(160)
         make.top.equalTo(welcomeText).inset(450)
     }
  }
    @objc func secondButton() {
        //MARK: - Анимация нажатия на кнопку
        UIView.animate(withDuration: 0.1, animations: {
               self.buttonAction.backgroundColor = .systemGray4
           }) { _ in
               UIView.animate(withDuration: 0.1) {
                   self.buttonAction.backgroundColor = .clear
               }
           }
        let rootVC = SecondViewController()
        rootVC.modalPresentationStyle = .fullScreen
        present(rootVC, animated: true)
    
    }
}
