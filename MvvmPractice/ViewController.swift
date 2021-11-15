//
//  ViewController.swift
//  MvvmPractice
//
//  Created by ed on 11/15/21.
//

import UIKit

// needs :
//observable obj
// model
// viewModels
// controller

//observable

class Observable<T>{
    
    // this object will be the holder between our controller
    // and our viewModel. 💀
    
    var value : T?{
        // setter
        didSet{
            listener?(value)
        }
    }
    
    init(_ value: T?){
        self.value = value
    }
    
    private var listener : ((T?) -> Void)?
    
    func bind(_ listener: @escaping (T?) -> Void){
        listener(value)
        self.listener = listener
    }
}


//model

struct User: Codable{
    let name:String
}

//viewModel

struct UserListViewModel{
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel{
    let name:String
}

//controller
class ViewController: UIViewController, UITableViewDataSource {
            
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self ,
                       forCellReuseIdentifier:"cell")
        return table
    }()
    
    // viewModel Instance
    private var viewModel = UserListViewModel()
    
    // table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        // weak self to avoid memory leaks
        viewModel.users.bind{[weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        fetch()
    }

    func fetch(){
        guard let url =
                URL(string: "https://jsonplaceholder.typicode.com/users")
                else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data,_,_) in
            guard let data = data else {return}
            do{
                // User model above
                let userModel = try JSONDecoder().decode([User].self, from: data)
                self.viewModel.users.value = userModel.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            }catch{
                
            }
        }
        task.resume()
    }
}

