//
//  DivisionStudyLevel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 19/04/2018.
//

import Fluent

public final class DivisionStudyLevel: PostgreSQLPivot, Migration {

    public typealias Left = Division

    public typealias Right = StudyLevel

    public var id: Identifier<DivisionStudyLevel>?

    public var divisionID: Identifier<Division>

    public var studyLevelID: Identifier<StudyLevel>

    public static var leftIDKey: LeftIDKey { return \.divisionID }

    public static var rightIDKey: RightIDKey { return \.studyLevelID }

    public init(divisionID: Identifier<Division>,
                studyLevelID: Identifier<StudyLevel>) {
        self.divisionID = divisionID
        self.studyLevelID = studyLevelID
    }
}
