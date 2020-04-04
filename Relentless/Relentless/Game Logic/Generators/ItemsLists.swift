//
//  ItemsLists.swift
//  Relentless
//
//  Created by Yi Wai Chow on 15/3/20.
//  Copyright © 2020 OurNameIs. All rights reserved.
//

import Foundation

class ItemsLists {

    /// At least three similar book titles will be picked together
    static let books = [[Book(name: "The title of the book is"),
                         Book(name: "The book title is title is")],
                        [Book(name: "The book title"),
                         Book(name: "Is the book title")],
                        [Book(name: "Book is the title"),
                         Book(name: "Is the title book")],
                        [Book(name: "Title is the book"),
                         Book(name: "The title title is the book title")]]

    /// At least two homophones will be picked together
    static let magazines = [[Magazine(name: "lamp"), Magazine(name: "lamb")],
                            [Magazine(name: "dew"), Magazine(name: "due")],
                            [Magazine(name: "hi"), Magazine(name: "high")],
                            [Magazine(name: "air"), Magazine(name: "heir")],
                            [Magazine(name: "aisle"), Magazine(name: "isle")],
                            [Magazine(name: "eye"), Magazine(name: "I")],
                            [Magazine(name: "bare"), Magazine(name: "bear")],
                            [Magazine(name: "be"), Magazine(name: "bee")],
                            [Magazine(name: "brake"), Magazine(name: "break")],
                            [Magazine(name: "buy"), Magazine(name: "by")],
                            [Magazine(name: "cell"), Magazine(name: "sell")],
                            [Magazine(name: "cent"), Magazine(name: "scent")],
                            [Magazine(name: "cereal"), Magazine(name: "serial")],
                            [Magazine(name: "coarse"), Magazine(name: "course")],
                            [Magazine(name: "complement"), Magazine(name: "compliment")],
                            [Magazine(name: "dam"), Magazine(name: "damn")],
                            [Magazine(name: "dear"), Magazine(name: "deer")],
                            [Magazine(name: "die"), Magazine(name: "dye")],
                            [Magazine(name: "fair"), Magazine(name: "fare")],
                            [Magazine(name: "fir"), Magazine(name: "fur")],
                            [Magazine(name: "four"), Magazine(name: "for")],
                            [Magazine(name: "hair"), Magazine(name: "hare")],
                            [Magazine(name: "hear"), Magazine(name: "here")],
                            [Magazine(name: "him"), Magazine(name: "hymn")],
                            [Magazine(name: "hole"), Magazine(name: "whole")],
                            [Magazine(name: "hour"), Magazine(name: "our")],
                            [Magazine(name: "idle"), Magazine(name: "idol")],
                            [Magazine(name: "in"), Magazine(name: "inn")],
                            [Magazine(name: "knight"), Magazine(name: "night")],
                            [Magazine(name: "knot"), Magazine(name: "not")],
                            [Magazine(name: "know"), Magazine(name: "no")]]

    /// At least two similar rhythms will be picked together
    static let robots = [[Robot(unitDuration: 1, stateSequence: [RhythmState.lit,
                                                                 RhythmState.unlit, RhythmState.lit]),
                          Robot(unitDuration: 2, stateSequence: [RhythmState.lit,
                                                                 RhythmState.unlit, RhythmState.lit])],
                         [Robot(unitDuration: 1, stateSequence: [RhythmState.unlit,
                                                                 RhythmState.lit, RhythmState.unlit]),
                          Robot(unitDuration: 1, stateSequence: [RhythmState.unlit, RhythmState.lit,
                                                                 RhythmState.lit])],
                         [Robot(unitDuration: 1, stateSequence: [RhythmState.lit, RhythmState.unlit,
                                                                 RhythmState.lit, RhythmState.unlit,
                                                                 RhythmState.lit]),
                          Robot(unitDuration: 1, stateSequence: [RhythmState.lit, RhythmState.unlit,
                                                                 RhythmState.lit, RhythmState.lit,
                                                                 RhythmState.unlit])]]
}
