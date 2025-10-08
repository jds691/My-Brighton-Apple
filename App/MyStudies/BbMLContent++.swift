//
//  BbMLContent++.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import SwiftBbML

nonisolated
extension BbMLContent {
    public static var exampleDocument: BbMLContent {
        try! BbMLParser().parse(
            """
            <!-- {"bbMLEditorVersion":1} -->
            
            <div data-bbid="bbml-editor-id_9c6a9556-80a5-496c-b10d-af2a9ab22d45">
            <h2>Header Large</h2>
            
            <h5>Header Medium</h5>
            
            <h6>Header Small</h6>
            
            <p>
            <strong>Bold</strong>
            <em>Italic<span style="text-decoration: underline;">Italic Underline</span></em>
            </p>
            
            <ul>
            <li>
            <span style="text-decoration: underline;"><em></em></span>Bullet 1
            </li>
            
            <li>Bullet 2</li>
            </ul>
            
            <p><img /></p>
            
            <p>
            <span>"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."</span>
            </p>
            
            <p><span>&lt;braces test="values" other="encoded values"&gt;</span></p>
            
            <p>Header Small</p>
            
            <ol>
            <li>Number 1</li>
            
            <li>Number 2</li>
            </ol>
            
            <p>
            Just words followed by a formula
            <img align="middle" alt="3 divided by 4 2 root of 7" class="Wirisformula" data-mathml="Â«mathxmlns=Â¨[http://www.w3.org/1998/Math/MathMLÂ¨Â»Â«mnÂ»3Â«/mnÂ»Â«moÂ»/Â«/moÂ»Â«mnÂ»4Â«/mnÂ»Â«mrootÂ»Â«mnÂ»7Â«/mnÂ»Â«mnÂ»2Â«/mnÂ»Â«/mrootÂ»Â«/mathÂ»](https://community.blackboard.com/external-link.jspa?url=http%3A//www.w3.org/1998/Math/MathML%25C2%25A8%25C2%25BB%25C2%25ABmn%25C2%25BB3%25C2%25AB/mn%25C2%25BB%25C2%25ABmo%25C2%25BB/%25C2%25AB/mo%25C2%25BB%25C2%25ABmn%25C2%25BB4%25C2%25AB/mn%25C2%25BB%25C2%25ABmroot%25C2%25BB%25C2%25ABmn%25C2%25BB7%25C2%25AB/mn%25C2%25BB%25C2%25ABmn%25C2%25BB2%25C2%25AB/mn%25C2%25BB%25C2%25AB/mroot%25C2%25BB%25C2%25AB/math%25C2%25BB)"/>
            </p>
            
            <p>
            <a href="[http://www.blackboard.com](https://community.blackboard.com/external-link.jspa?url=http%3A//www.blackboard.com/)">Blackboard</a>
            </p>
            </div>
            """
        )
    }
}
