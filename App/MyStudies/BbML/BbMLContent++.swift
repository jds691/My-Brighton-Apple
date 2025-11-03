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
            <h4>Header Large</h4>
            
            <h5>Header Medium</h5>
            
            <h6>Header Small</h6>
            
            <p><strong>Bold</strong>
            <em>Italic<span style="text-decoration: underline">Italic Underline</span></em>
            </p>
            
            <ul><li><span style="text-decoration: underline"><em></em></span>Bullet 1</li>
            
            <li>Bullet 2</li>
            </ul>
            
            <p><img /></p>
            
            <p><span
            >"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
            eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
            ad minim veniam, quis nostrud exercitation ullamco laboris."</span
            >
            </p>
            
            <p><span>&lt;braces test="values" other="encoded values"&gt;</span></p>
            
            <p>Header Small</p>
            
            <ol>
            <li>Number 1</li>
            
            <li>Number 2</li>
            </ol>
            
            <p>Just words followed by a formula
            <img
            align="middle"
            alt="3 divided by 4 2 root of 7"
            class="Wirisformula"
            data-mathml="Â«mathxmlns=Â¨[http://www.w3.org/1998/Math/MathMLÂ¨Â»Â«mnÂ»3Â«/mnÂ»Â«moÂ»/Â«/moÂ»Â«mnÂ»4Â«/mnÂ»Â«mrootÂ»Â«mnÂ»7Â«/mnÂ»Â«mnÂ»2Â«/mnÂ»Â«/mrootÂ»Â«/mathÂ»](https://community.blackboard.com/external-link.jspa?url=http%3A//www.w3.org/1998/Math/MathML%25C2%25A8%25C2%25BB%25C2%25ABmn%25C2%25BB3%25C2%25AB/mn%25C2%25BB%25C2%25ABmo%25C2%25BB/%25C2%25AB/mo%25C2%25BB%25C2%25ABmn%25C2%25BB4%25C2%25AB/mn%25C2%25BB%25C2%25ABmroot%25C2%25BB%25C2%25ABmn%25C2%25BB7%25C2%25AB/mn%25C2%25BB%25C2%25ABmn%25C2%25BB2%25C2%25AB/mn%25C2%25BB%25C2%25AB/mroot%25C2%25BB%25C2%25AB/math%25C2%25BB)"
            />
            </p>
            
            <p>
            <a
            href="[http://www.blackboard.com](https://community.blackboard.com/external-link.jspa?url=http%3A//www.blackboard.com/)"
            >Blackboard</a
            >
            </p>
            </div>

            """
        )
    }

    public static var examplePost: BbMLContent {
        try! BbMLParser().parse(
            """
            <div data-bbid="bbml-editor-id_e8f01344-60df-43ef-a2eb-8c5468de4aed">
            <h4>
            <span style="color: #1c8845"
            ><span style="font-family: Arial"
                ><strong
                    >Learning outcomes. By the end of the week you should
                    have:</strong
                ></span
            ></span
            >
            </h4>
            <ul>
            <li>
            a basic learning journal online at<a
                href="https://brighton.domains/"
                >&nbsp;BrightonDomains</a
            >&nbsp;(instructions for this in the&nbsp;<a
                href="http://jh1033.brighton.domains/ci435/tutorials/induction/induction.html"
                >Induction Lab</a
            >)
            </li>
            <li>
            some practical experience in using and understanding basic html tags
            </li>
            <li>have validated your HTML</li>
            <li>
            read the assignment (in Assessments folder) and ask your tutor or
            lecturer any questions. You start it by completing the tutorials
            </li>
            </ul>
            </div>
            <div data-bbid="bbml-editor-id_924ca699-09e0-4434-ad91-6a4b9c469cdc">
            <h4><span style="color: #1c8845">Pre-lecture</span></h4>
            <ul>
            <li>
            Find either a 'good' or a 'bad' webpage - can you explain why you
            think this? Website design and evaluation:&nbsp;<a
                href="https://www.w3.org/wiki/What_does_a_good_web_page_need"
                ><span style="color: #1874a4"
                    >https://www.w3.org/wiki/What_does_a_good_web_page_need</span
                ></a
            >&nbsp;and&nbsp;<a
                href="https://blog.hubspot.com/website/bad-vs-good-design#:~:text=There%20are%20six%20things%20bad%20websites%20have%20in,feature%20poor%20design%20is%20a%20lack%20of%20user-centricity."
                >Examples of Bad Website Design</a
            >&nbsp;(from last week - you can still add to discussion). Find the
            module discussion board, and put your own examples - with a brief
            explanation of why you think it is good or bad. What are your
            criteria?
            </li>
            <li>
            Make sure that you can<span style="color: #e72218"
                >&nbsp;log onto BrightonDomains. Contact IT Support from your
                university email if you are still having problems with this
                (allow 24h after completing your university enrolment.).</span
            >
            </li>
            <li>Complete all previous tutorials.</li>
            </ul>
            </div>
            <a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-18895935_1/xid-18895935_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=00qHsDLaNslPSrycw1Uw02jzNjGjrcrbq2taolzFJjg%3D"
            data-bbid="bbml-editor-id_16580ef0-d09b-47ba-b1be-3feae10e87cd"
            data-bbfile='{"render":"inline","alternativeText":"lecture teacher board","linkName":"lecture.png","mimeType":"image/png"}'
            >lecture.png</a
            >
            <div data-bbid="bbml-editor-id_492453f8-c0d4-477f-9dfe-3cca5956ed6e">
            <h4>
            <span style="color: #1c8845"><strong>Lecture</strong></span>
            </h4>
            <p>
            <span style="color: #000000">The lecture&nbsp;</span>introduces basic
            HTML markup and the semester assessment.
            </p>
            <p>
            <span style="color: #000000"
            >Slides in ppt and pdf format are available here.</span
            >
            </p>
            <p>
            <a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-19181760_1/xid-19181760_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=x8k34mKlVOMbcuK%2BPwWh%2B3zEHqVvEXiCy2ZNAYguV8Q%3D"
            data-bbtype="attachment"
            data-bbfile='{"alternativeText":"02HTMLbasics.pptx","displayName":"02HTMLbasics.pptx","fileName":"02HTMLbasics.pptx","fileSize":349655,"mimeType":"application/vnd.openxmlformats-officedocument.presentationml.presentation","render":"inline","resourceUrl":"https://studentcentral.brighton.ac.uk/sessions/A2/A2B7B94BD7318DAA206DFEDB28927F9F/72cc8761330644cb87651ccc49d442d9/02HTMLbasics.pptx","linkName":"02HTMLbasics.pptx","viewerUrl":"https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-19181760_1/xid-19181760_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=x8k34mKlVOMbcuK%2BPwWh%2B3zEHqVvEXiCy2ZNAYguV8Q%3D?locale=en_GB&amp;isInlineRender=true&amp;xythos-download=true&amp;render=inline"}'
            >02HTMLbasics.pptx</a
            ><a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-19181758_1/xid-19181758_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=%2BhwipOkN%2BMZIiYgAO%2F9gklibrwoKJNg1Hzv%2B8vQFVQE%3D"
            data-bbtype="attachment"
            data-bbfile='{"alternativeText":"02HTMLbasics.pdf","displayName":"02HTMLbasics.pdf","fileName":"02HTMLbasics.pdf","fileSize":526024,"mimeType":"application/pdf","render":"inline","resourceUrl":"https://studentcentral.brighton.ac.uk/sessions/A2/A2B7B94BD7318DAA206DFEDB28927F9F/30ecf4acebd84e678f9a8e2139f29ee5/02HTMLbasics.pdf","linkName":"02HTMLbasics.pdf","viewerUrl":"https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-19181758_1/xid-19181758_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=%2BhwipOkN%2BMZIiYgAO%2F9gklibrwoKJNg1Hzv%2B8vQFVQE%3D?locale=en_GB&amp;isInlineRender=true&amp;xythos-download=true&amp;render=inline"}'
            >02HTMLbasics.pdf</a
            >
            </p>
            </div>
            <a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-18895940_1/xid-18895940_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=SJMz9FuRKN4f1fDCjgQKxgKwXjIZ1BX%2B%2FEUFdLdQLBE%3D"
            data-bbid="bbml-editor-id_081f10e8-fcb6-4f94-bf6a-0243ea0cf152"
            data-bbfile='{"render":"inlineOnly","alternativeText":"practical lab work","linkName":"practical.png","mimeType":"image/png"}'
            >practical.png</a
            >
            <div data-bbid="bbml-editor-id_2aecef2b-9b7b-487f-95ae-3368227a5775">
            <h4>
            <span style="color: #1c8845"
            ><strong>Lab and Independent Work</strong></span
            >
            </h4>
            <p>
            In this week's lab tutorial you will write some posts in the learning
            journal that you started last week and mark this up using different HTML
            tags.If you did not complete the Induction Tutorial or Lab Tutorial Week
            1 last week please do these first.
            </p>
            <p>
            <span style="color: #000000"
            >Here is the online tutorial for this week. You won't be able to
            finish all of this in class - you should work at your own pace and
            either complete them on your own, or in the following week's class.
            You will need to review the lecture material too. Make notes so that
            you don't need to remember everything, and record any questions to
            bring to you lab classes.&nbsp;</span
            >
            </p>
            <p>
            <span style="color: #000000">Open the tutorial web page in&nbsp;</span
            ><strong>Chrome</strong>&nbsp;or&nbsp;<strong>FireFox</strong>, in a new
            tab or window.
            </p>
            <ul>
            <li>
            Lab Practical - Index:&nbsp;<a
                href="http://jh1033.brighton.domains/ci435/tutorials/index.html"
                >http://jh1033.brighton.domains/ci435/tutorials/index.html</a
            >
            </li>
            <li>
            Lab Practical - Week 2:&nbsp;<a
                href="http://jh1033.brighton.domains/ci435/tutorials/tutorial02.html"
                ><span style="color: #1874a4"
                    >http://jh1033.brighton.domains/ci435/tutorials/tutorial02.html</span
                ></a
            >
            </li>
            </ul>
            <p>
            <span style="color: #000000"
            >You will need to refer to the MDN HTML Element Index or similar to
            look up the names and meaning of HTML elements.</span
            >
            </p>
            <ul>
            <li>
            <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Element"
                ><span style="color: #1874a4"
                    >https://developer.mozilla.org/en-US/docs/Web/HTML/Element</span
                ></a
            >
            </li>
            <li>
            <a href="http://html5doctor.com/element-index/"
                >http://html5doctor.com/element-index/</a
            >
            </li>
            </ul>
            <p>
            <span style="color: #000000"
            >By the end of the tutorial your learning journal might look
            something like this:</span
            >
            </p>
            <ul>
            <li>
            <a
                href="http://jh1033.brighton.domains/ci435/tutorials/learningJournal/index_2.html"
                ><span style="color: #1874a4"
                    >http://jh1033.brighton.domains/ci435/tutorials/learningJournal/index_2.html</span
                ></a
            >
            </li>
            </ul>
            <p>
            <span style="color: #000000"
            >You should have a copy of your files on the server and locally. You
            should be clear which is most recent, if they are not the same. Your
            pages should be validated, and you should be viewing them through
            the server (via your URL). You should know your URL.&nbsp;</span
            >
            </p>
            <h5><span style="color: #e72218">EXTENSION TASKS&nbsp;</span></h5>
            <h6>
            <span style="color: #000000"
            >Using FTP (File Transfer Protocol)&nbsp;</span
            >
            </h6>
            <p>
            You may wish to use software to manage the connection between your local
            computer and the server. If you do, follow the instructions in the
            document attached to the&nbsp;<strong>Induction Lab &gt;</strong
            >&nbsp;&nbsp;<strong>UsingBrightonDomainsToHostAWebsite.pdf&nbsp;</strong>or
            (more generic) here&nbsp;<a
            href="http://brighton.domains/docs/uncategorized/setting-up-ftp/"
            >http://brighton.domains/docs/uncategorized/setting-up-ftp/&nbsp;</a
            >
            </p>
            <h6>Start the assignment tutorial page&nbsp;</h6>
            <p>
            You will be starting the index / learning journal page by completing the
            online tutorials (above). Read the assignment - you'll see that the
            second page requires you to develop a study skill. You could start
            thinking about this now.
            </p>
            </div>
            <a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-18895941_1/xid-18895941_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=XRBPTLPRDfV%2B2XgRcQ88AX5ft0JIQTZZ%2Fsp%2B0Ra%2FEVo%3D"
            data-bbid="bbml-editor-id_d9d0b4af-da95-4f4d-ad73-1e0ab686981c"
            data-bbfile='{"render":"inlineOnly","alternativeText":"Working Together","linkName":"Working Together","mimeType":"image/jpeg"}'
            >Working Together</a
            >
            <div data-bbid="bbml-editor-id_f7136f68-2894-4111-964e-03ae20f8c873">
            <h4><span style="color: #1c8845">Working Together</span></h4>
            <p>
            Share your good / bad websites, helpful reading, problem solving
            etc.&nbsp;
            </p>
            <p>Give each other feedback on learning journal so far:</p>
            <ul>
            <li>available through the web server</li>
            <li>easy to read? Both content and style</li>
            <li>
            informative - includes references and examples - evidence of
            independent work
            </li>
            <li>
            show development e.g. before and after screenshots - maybe annotated
            (might not be in website yet, but ready to be used)?
            </li>
            </ul>
            </div>
            <a
            href="https://studentcentral.brighton.ac.uk/bbcswebdav/pid-4731533-dt-content-rid-18895942_1/xid-18895942_1?Kq3cZcYS15=6540ca5d40e84a9e9cd9d90ce3424a07&VxJw3wfC56=1761330196&3cCnGYSz89=LrD9iXrf9US0Fp2rtLAK6rMP%2F07Xk90SR0ek3rGI%2BZo%3D"
            data-bbid="bbml-editor-id_cd647461-6db6-4529-b6f7-b0bfb1047e95"
            data-bbfile='{"render":"inlineOnly","alternativeText":"reading and research","linkName":"reading.png","mimeType":"image/png"}'
            >reading.png</a
            >
            <div data-bbid="bbml-editor-id_41b60bd7-12dd-40d2-823a-b7c6919d587d">
            <h4><span style="color: #1c8845">Reading / Extension Suggestions</span></h4>
            <ul>
            <li>
            MDN - Getting Started with HTML&nbsp;<a
                href="https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/Getting_started"
                ><span style="color: #1874a4"
                    >https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/Getting_started</span
                ></a
            >
            </li>
            <li>
            <span style="color: #000000">What Is an HTML Element?</span
            ><span style="color: #1874a4">&nbsp;-&nbsp;</span
            ><a href="https://developer.mozilla.org/en-US/docs/Glossary/Element"
                >https://developer.mozilla.org/en-US/docs/Glossary/Element</a
            >
            </li>
            <li>
            <a href="https://www.w3.org/Consortium/"
                ><span style="color: black">W3C&nbsp;</span></a
            >&nbsp;- The standards body agreeing the meani<span
                style="color: black"
                >ng and correct usage of tag -</span
            >&nbsp;they also supply the validators (<a
                href="https://validator.w3.org/"
                >html&nbsp;</a
            >and&nbsp;<a href="https://jigsaw.w3.org/css-validator/">css</a>) to
            check that your code meets the standards
            </li>
            <li>
            Reference lists and tutorials&nbsp;<a
                href="https://developer.mozilla.org/en-US/docs/Web/HTML/Element"
                >https://developer.mozilla.org/en-US/docs/Web/HTML/Element</a
            >&nbsp;have a look at all the available tags
            </li>
            <li>
            <span style="color: #000000"
                >Web-based research – find out about “block and inline elements”
                and "absolute and relative" links</span
            >
            </li>
            <li>
            <span style="color: #000000">Read about the&nbsp;</span
            ><a href="https://en.wikipedia.org/wiki/ISO_8601"
                ><span style="color: #1874a4"
                    >ISO 8601 international standard for dates and times</span
                ></a
            >, used in HTML5
            </li>
            <li>
            Check out the video tutorials on&nbsp;<a
                href="https://www.linkedin.com/checkpoint/enterprise/login/67552674?pathWildcard=67552674&amp;application=learning&amp;redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fcollections%2F6564799543815340032%3Fu%3D67552674"
                ><span style="color: #1874a4"
                    >Linked In Learning playlist</span
                ></a
            >
            </li>
            <li>
            <span style="color: #000000">Jon Duckett,&nbsp;</span
            ><em>HTML &amp; CSS: design and build websites.</em>&nbsp;Read
            Chapters 2 (Text), 3 (Lists) and 4 (Links).
            </li>
            </ul>
            <br />
            <p>
            <em>Independent researc</em>h is one of the assessed criteria in the
            coursework assignment. Start here, and include references to what you
            have learned in your Learning Journal.
            </p>
            </div>

            """
        )
    }
}
