//
//  HiddenRowsExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

public struct Care: Equatable, Hashable {
    public let id: Int
    public let name: String
    public let shouldShowNewRow: Bool
}

extension Care: CustomStringConvertible {
    public var description: String {
        return name
    }
}
let cares = [
    Care(id: 1, name: "Not show", shouldShowNewRow: false),
    Care(id: 2, name: "Not show either", shouldShowNewRow: false),
    Care(id: 3, name: "Show bug!!!", shouldShowNewRow: true),
]

public struct Address: Equatable, Hashable {
    public let id: Int?
    public let name: String
    public let street: String
}

extension Address: CustomStringConvertible {
    public var description: String {
        return UUID().uuidString
    }
}

let addresses = [
    Address(id: 1, name: "Address1", street: "Street...."),
    Address(id: 2, name: "Address2", street: "Street...."),
    Address(id: 3, name: "Address3", street: "Street...."),
    Address(id: 4, name: "Address4", street: "Street....")
]

class HiddenRowsExample : FormViewController {

    init() {
        super.init(style: UITableView.Style.grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        }

        form = Section("What do you want to talk about:")
            <<< SegmentedRow<String>("segments"){
                $0.options = ["Sport", "Music", "Films"]
                $0.value = "Films"
            }
            +++ Section(){
                $0.tag = "sport_s"
                $0.hidden = "$segments != 'Sport'" // .Predicate(NSPredicate(format: "$segments != 'Sport'"))
            }
            <<< TextRow(){
                $0.title = "Which is your favourite soccer player?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite coach?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite team?"
            }

            +++ Section(){
                $0.tag = "music_s"
                $0.hidden = "$segments != 'Music'"
            }
            <<< TextRow(){
                $0.title = "Which music style do you like most?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite singer?"
            }
            <<< TextRow(){
                $0.title = "How many CDs have you got?"
            }

            +++ Section(){
                $0.tag = "films_s"
                $0.hidden = "$segments != 'Films'"
            }
            <<< TextRow(){
                $0.title = "Which is your favourite actor?"
            }

            <<< TextRow(){
                $0.title = "Which is your favourite film?"
            }

            +++ Section()

            <<< SwitchRow("Show Next Row"){
                $0.title = $0.tag
            }
            <<< SwitchRow("Show Next Section"){
                $0.title = $0.tag
                $0.hidden = .function(["Show Next Row"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Row")
                    return row.value ?? false == false
                })
            }

            +++ Section(footer: "This section is shown only when 'Show Next Row' switch is enabled"){
                $0.hidden = .function(["Show Next Section"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Show Next Section")
                    return row.value ?? false == false
                })
            }
            <<< TextRow() {
                $0.placeholder = "Gonna dissapear soon!!"
            }

            +++ Section("Photos")

            <<< ImageRow {
                $0.title = "Some nice photo"
            }

            <<< ImageRow {
                $0.title = "Some nice photo"
            }

            <<< ImageRow {
                $0.title = "Some nice photo"
            }

            <<< ImageRow {
                $0.title = "Some nice photo"
            }


            +++ Section("My MultipleSelectorRow")

            <<< MultipleSelectorRow<Care> {
                $0.title = "Pick one Care"
                $0.tag = "MultipleSelectorRow"
                $0.options = cares
                }.onPresent { [weak self] from, to in
                    to.navigationItem.rightBarButtonItem = self?.multipleSelectorDoneButton(from)
            }

            <<< MultipleSelectorRow<String> {
                $0.title = "Pick other number"
                $0.tag = "OtherMultipleSelectorRow"
                $0.options = ["1", "2", "3", "4"]
                }.onPresent { [weak self] from, to in
                    to.navigationItem.rightBarButtonItem = self?.multipleSelectorDoneButton(from)
            }

            let section = addressPushRowSection()

            section.hidden = .function(["MultipleSelectorRow"]) { form -> Bool in
                guard let row = form.rowBy(tag: "MultipleSelectorRow") as? MultipleSelectorRow<Care>,
                    let array = row.value else {
                        return true
                }

                return !array.contains(where: { $0.shouldShowNewRow == true })
            }

            form +++ section

            form +++ Section("Photos")

            <<< ImageRow {
                $0.title = "Some nice photo"
            }

            +++ Section(
                header: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In eget tortor sit amet nibh lacinia.",
                footer: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus orci neque, gravida ut nunc ut, rhoncus pulvinar nisi. Ut eget quam consequat, tristique nunc eu, suscipit lorem. Praesent in nisl enim. Ut leo eros, feugiat a dapibus et, finibus a sapien. Vivamus interdum sem turpis, ut molestie arcu tristique eget. Suspendisse nunc elit, scelerisque non libero nec, aliquet lacinia elit. Mauris fringilla mauris eros, ut mollis dui accumsan sit amet."
            )

            <<< DateTimeRow {
                $0.title = "Date"
                $0.value = Date()
                $0.minimumDate = Date()
            }

            +++ Section("Other Section header")

            <<< MultipleSelectorRow<String> {
                $0.title = "Pick one emoji"
                $0.options = ["🤯", "🤔", "🙄", "😡"]
            }

            +++ Section()

            <<< TextAreaRow {
                $0.placeholder = "Big text"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
            }

            <<< TextAreaRow {
                $0.placeholder = "Big text"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
        }
    }

    private func addressPushRowSection() -> Section {
        return Section("Address")
            <<< PushRow<Address> {
                $0.title = "Address"
                $0.options = addresses
                $0.selectorTitle = "Pick one address"
                $0.displayValueFor = { address in return address?.name }
                }.onPresent { [weak self] from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = false
                    to.row.displayValueFor = { address in return address?.name }
                    to.navigationItem.rightBarButtonItem = self?.multipleSelectorDoneButton(from)
                }
    }

    private func multipleSelectorDoneButton(_ from: UIViewController) -> UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .done,
            target: from,
            action: #selector(HiddenRowsExample.multipleSelectorDone(_:))
        )
    }

    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}
