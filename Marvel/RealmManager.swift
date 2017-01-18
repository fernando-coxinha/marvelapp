//
//  RealmManager.swift
//  Marvel
//
//  Created by Thiago Lioy on 17/01/17.
//  Copyright © 2017 Thiago Lioy. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift

class FavoriteCharacter: Object {
    dynamic var id = 0
    dynamic var isFavorite = true
    
    convenience init(character: Character) {
        self.init()
        id = character.id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct RealmManager {
    
    let disposeBag = DisposeBag()
    
    func isFavorite(character: Character) -> Observable<FavoriteCharacter>{
        return favorites(filter: "id == \(character.id)")
    }
    
    func favorite(character: Character) {
        let favorite = FavoriteCharacter(character: character)
        Observable.just(favorite)
            .subscribe(Realm.rx.add())
            .addDisposableTo(disposeBag)
    }
    
    func favorites(filter predicateFormat: String? = nil) -> Observable<FavoriteCharacter> {
        guard let realm = try? Realm() else {
            return Observable.empty()
        }
        var results = realm.objects(FavoriteCharacter.self)
        if let predicate = predicateFormat {
            results = results.filter(predicate)
        }
        let list = results.toArray()
        return Observable.from(list)
    }
    
    func unfavorite(character: Character) {
        favorites(filter: "id == \(character.id)")
            .subscribe(Realm.rx.delete())
            .addDisposableTo(disposeBag)
    }
    
}
