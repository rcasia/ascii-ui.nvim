# Changelog

## [0.5.0](https://github.com/rcasia/ascii-ui.nvim/compare/v0.4.0...v0.5.0) (2025-09-13)


### Features

* add log level to user configuration ([30ebdff](https://github.com/rcasia/ascii-ui.nvim/commit/30ebdff8382fd4143e5f8c28537607c53ed14eef))
* **block:** expose component blocks to public api ([c20a96b](https://github.com/rcasia/ascii-ui.nvim/commit/c20a96b82a88b02c5cb84e1714640b7bd71eb2e8))
* capture user config on plugin init ([ef0b50e](https://github.com/rcasia/ascii-ui.nvim/commit/ef0b50ede11166cc8931fb7948e35ccfba21ee69))
* **dsl:** support xml definitions in new fiber architecture ([a05da17](https://github.com/rcasia/ascii-ui.nvim/commit/a05da17324a549c0e4f6c2e6c40a16670fdbf624))
* **hooks:** add use_interval hook ([d36bd58](https://github.com/rcasia/ascii-ui.nvim/commit/d36bd588acd57c7835b34934db256addea5e6758))
* **hooks:** add useTimeout hook ([d58cb2c](https://github.com/rcasia/ascii-ui.nvim/commit/d58cb2c51b8c7a86cf70dd1dcc936f07516f587e))
* **hooks:** create useConfig hook ([358002f](https://github.com/rcasia/ascii-ui.nvim/commit/358002f914b20ac965fff4c08c021e104905934c))
* let the user return a list of fibernodes for custom components ([d2b528c](https://github.com/rcasia/ascii-ui.nvim/commit/d2b528c493cda53eb87f71eaff46033e028f369a))
* **paragraph:** support for newlines ([009237b](https://github.com/rcasia/ascii-ui.nvim/commit/009237b43d329da0c7c8436bafa81849acc2796b))
* remove the requirement for the user to use an inner function for component definitions ([c28ee19](https://github.com/rcasia/ascii-ui.nvim/commit/c28ee19ef937cac34937930fd042b80c883ce2bb))
* **slider:** add on_change prop to slider component ([5c7eedd](https://github.com/rcasia/ascii-ui.nvim/commit/5c7eedd237e2a0d0bf1f75735c6f402209530448))
* **tree:** better tree drawing ([5e70d37](https://github.com/rcasia/ascii-ui.nvim/commit/5e70d37020e6ab856f278f405a95774c50afd776))
* **tree:** use user config to render tree component ([9197abd](https://github.com/rcasia/ascii-ui.nvim/commit/9197abdaa3a4295f6c56d34297d41146f1c52a95))
* use mini.test as dependency ([4a8824f](https://github.com/rcasia/ascii-ui.nvim/commit/4a8824f26c148d72ccb176e4fb6a45b7f09d029d))


### Bug Fixes

* remove pending effects assertion ([591094b](https://github.com/rcasia/ascii-ui.nvim/commit/591094bced6d51dc16e68c9c2b0ce4238af025d1))
* return a deep copy of the state to avoid mutation ([17be7dd](https://github.com/rcasia/ascii-ui.nvim/commit/17be7dd779dc83a7b2c06ed26cd60b9afc5257eb))

## [0.4.0](https://github.com/rcasia/ascii-ui.nvim/compare/v0.3.0...v0.4.0) (2025-07-27)


### ⚠ BREAKING CHANGES

* first fiber implementation ([#35](https://github.com/rcasia/ascii-ui.nvim/issues/35))

### Features

* add hexacolor.lua ([8a477fd](https://github.com/rcasia/ascii-ui.nvim/commit/8a477fd56e65dbf37ab686bc3c500c81d6c3e00c))
* add iter function to FiberNode ([8964264](https://github.com/rcasia/ascii-ui.nvim/commit/89642645226e78477d3b788944c5b380fa286602))
* add props_are_equal for prop comparison ([9974603](https://github.com/rcasia/ascii-ui.nvim/commit/9974603b38c4c6479789cddaca9c38ea1a192dbe))
* add static method to recognize Buffer, Bufferline and Segment ([a958d49](https://github.com/rcasia/ascii-ui.nvim/commit/a958d4959c379323b47bd6f120527f46d5be974f))
* changes on component props are reflected when depending on ancestors hooks ([c005e6a](https://github.com/rcasia/ascii-ui.nvim/commit/c005e6ab848ec2217becc8574a8228aee95f27f4))
* expose fiber's useState and useEffect ([635a2d9](https://github.com/rcasia/ascii-ui.nvim/commit/635a2d99d613e40e53229e42b6a4fd95f4ac5108))
* **fibernode:** expand fibernode methods ([01593eb](https://github.com/rcasia/ascii-ui.nvim/commit/01593ebe7e6ce3292014d95c610800b7e9c2807c))
* first fiber implementation ([#35](https://github.com/rcasia/ascii-ui.nvim/issues/35)) ([32bcd8d](https://github.com/rcasia/ascii-ui.nvim/commit/32bcd8d9f440f6bfebfba661db6f8bc3c65d5b9d))
* use fiber tags for rerendering control ([126bfc3](https://github.com/rcasia/ascii-ui.nvim/commit/126bfc322c1f4bf37880fc933bd1ceeb5304306d))


### Bug Fixes

* avoid infinite rerenders when there a useState.set invocation inside an useEffect ([#39](https://github.com/rcasia/ascii-ui.nvim/issues/39)) ([0522237](https://github.com/rcasia/ascii-ui.nvim/commit/05222371ba152e752760734543c8f043006dc6d7))
* cursor focuses on last focusable on left ([ab446c0](https://github.com/rcasia/ascii-ui.nvim/commit/ab446c0649a8c5f69e109d67f13d9313785fd0a1))
* cursor focuses on next focusable on right ([cb507a5](https://github.com/rcasia/ascii-ui.nvim/commit/cb507a52c67b37aea69b7ba7f7056a187df4e086))
* do not call cleanup when setting value in useState ([43fbca1](https://github.com/rcasia/ascii-ui.nvim/commit/43fbca1ed1164bc91aad2ec1d94404214c189f22))
* find element when selecting on it by the left edge ([34642e0](https://github.com/rcasia/ascii-ui.nvim/commit/34642e09d1a92ec54be70ce4de5d3754f2c879b1))
* recognize focusables that are not the first in line ([be7253f](https://github.com/rcasia/ascii-ui.nvim/commit/be7253fa0784ddae5c05281747026bb35f670793))
* set col count to keep into account utf-32 as before ([4dca51c](https://github.com/rcasia/ascii-ui.nvim/commit/4dca51c372d156217000be079e4182fa2e46a7b4))
* **slider:** use correct hook for initial value ([7483a53](https://github.com/rcasia/ascii-ui.nvim/commit/7483a534c707f11f1c5e185caa349f68ef5cb671))
* when cursor cannot go up does not go left anymore ([8170569](https://github.com/rcasia/ascii-ui.nvim/commit/8170569c18f5daa342bb1c5f3dec663ca1ca7a84))


### Miscellaneous Chores

* release 0.4.0 ([0df3cbe](https://github.com/rcasia/ascii-ui.nvim/commit/0df3cbe14f2241004b048b1a75ebcd039048b3ad))

## [0.3.0](https://github.com/rcasia/ascii-ui.nvim/compare/v0.2.0...v0.3.0) (2025-06-01)


### Features

* **dsl:** function references can be passed to components in xml ([064c3af](https://github.com/rcasia/ascii-ui.nvim/commit/064c3afe42c8d426d1747550c6dd9097bdb76b1a))
* **hooks:** create useFunctionRegistry hook ([52af8e7](https://github.com/rcasia/ascii-ui.nvim/commit/52af8e7b05039e4ec698cf0d6e8e3a3088b4c622))
* **hooks:** expose api for useEffect and useFunctionRegistry ([7f501fd](https://github.com/rcasia/ascii-ui.nvim/commit/7f501fdc1b71a5c1204cbe8449beb1afd96339ba))
* **hooks:** useEffect runs clean up function on ui close event ([30de36d](https://github.com/rcasia/ascii-ui.nvim/commit/30de36d92b2bd2f1c07f2dccef74c689173d89a4))
* **hooks:** useEffect runs clean up function when dependencies change ([b8b75e8](https://github.com/rcasia/ascii-ui.nvim/commit/b8b75e846e0b75cf5a9b47d8e4d8c2066580cc71))
* **hooks:** useState accepts a function parameter on the setter function ([e62a3c7](https://github.com/rcasia/ascii-ui.nvim/commit/e62a3c78d0a245e0c6dd66c3a1acd8be785d33e7))
* pass the config in the component closure param ([ede9faa](https://github.com/rcasia/ascii-ui.nvim/commit/ede9faa0f7d9906f388a19194a306b6060907d20))
* renderer recieves a function that returns a function, bufferlines or a xml string ([a52c4ce](https://github.com/rcasia/ascii-ui.nvim/commit/a52c4ce6b5e9c3ce5f68595b74982b03eb7b6f0a))
* **segment:** count length taking into account unicode characters ([926a225](https://github.com/rcasia/ascii-ui.nvim/commit/926a225686e6709c730522c628137d4b0daa5a4d))
* **tree:** created tree component ([e695605](https://github.com/rcasia/ascii-ui.nvim/commit/e6956056dd4e905d896f959b21f8af8566ec59df))
* **tree:** renders a last leaf node with ending prefix ([593df5c](https://github.com/rcasia/ascii-ui.nvim/commit/593df5cd1f20f3c82ed64d4fae4a85835366fc69))
* **tree:** renders a tree with only one child ([90b6f68](https://github.com/rcasia/ascii-ui.nvim/commit/90b6f6899294fad568f565c58ba51966671a1562))
* **tree:** renders a tree with two children ([96d3c34](https://github.com/rcasia/ascii-ui.nvim/commit/96d3c3485c5ab27008a78241bea51ce9f730bcd1))
* **tree:** renders a tree with two children having a third level ([11133f5](https://github.com/rcasia/ascii-ui.nvim/commit/11133f529807e5073ad1af8a07105a3535bed213))
* **tree:** renders character to signal there are collapsed nodes ([c969d40](https://github.com/rcasia/ascii-ui.nvim/commit/c969d40b6cc74ee71b55c87352639542d1c84a60))
* **tree:** renders character to signal there are expanded nodes ([d6f4134](https://github.com/rcasia/ascii-ui.nvim/commit/d6f41340583ba36a1049708ad9eedaf73453136d))
* **tree:** renders last level one node with space before its children ([73be798](https://github.com/rcasia/ascii-ui.nvim/commit/73be798b1b73602f7b76745fa229e59ed7a39b09))
* **tree:** set focusable segments in a tree ([adbda8b](https://github.com/rcasia/ascii-ui.nvim/commit/adbda8b1f9b0c420ddc56164590403fb8d28c834))
* use cursor nvim api functions just in Cursor module ([727c3d6](https://github.com/rcasia/ascii-ui.nvim/commit/727c3d6c75c8aa18835879520aae88124dd94083))
* **window:** make the floating window draggable ([90ee93f](https://github.com/rcasia/ascii-ui.nvim/commit/90ee93f7d9d0df7dd1ebb25c3d3be149b4208498))


### Bug Fixes

* don't listen key interactions when no on ui window ([b82420e](https://github.com/rcasia/ascii-ui.nvim/commit/b82420ea2ff1dceefc30f64636d9ceb4ca32baf5))
* get current position without counting extra unicode bytes ([11d649f](https://github.com/rcasia/ascii-ui.nvim/commit/11d649fad3253b07f99889c06f6200a43f7062b1))
* prevent changing modifiable attribute when window has no winid or burnr ([c45bad5](https://github.com/rcasia/ascii-ui.nvim/commit/c45bad5fcdc4d9ffe3e86a59ddb70db338027fe3))
* remove autocommand when components are unmounted ([a01ada0](https://github.com/rcasia/ascii-ui.nvim/commit/a01ada07938b4f1dde1a49f57f06ffc00300b297)), closes [#25](https://github.com/rcasia/ascii-ui.nvim/issues/25)


### Performance Improvements

* throttle window drag updates ([4fc6a69](https://github.com/rcasia/ascii-ui.nvim/commit/4fc6a69df7888f0f3502c5389936c34e1e40ae5c))

## [0.2.0](https://github.com/rcasia/ascii-ui.nvim/compare/v0.1.0...v0.2.0) (2025-05-21)


### Features

* add component validation on component definition call ([8122350](https://github.com/rcasia/ascii-ui.nvim/commit/8122350da8249e51444b0feef084eec8070def34))
* Add partial implementation of a DSL ([#9](https://github.com/rcasia/ascii-ui.nvim/issues/9)) ([2d58532](https://github.com/rcasia/ascii-ui.nvim/commit/2d58532e232f148313e06e50f9e34e1e3acfa672))
* avoid memoize in paragraph and box ([dbb3cb4](https://github.com/rcasia/ascii-ui.nvim/commit/dbb3cb425af1d48e02450ea9e101144a540b471e))
* **button:** avoid memoization in button as it is not stateful ([eb3fb5c](https://github.com/rcasia/ascii-ui.nvim/commit/eb3fb5cc72f57355fae9762505bb1e2376116c5a))
* clear event listener when window is closed ([4929826](https://github.com/rcasia/ascii-ui.nvim/commit/49298260453b0a414b87cf97818d02109ed6bd28))
* create component ([bf58990](https://github.com/rcasia/ascii-ui.nvim/commit/bf58990a27b1d28535c35339b8bc1961fc83a16c))
* create useEffect hook ([8fcc1b9](https://github.com/rcasia/ascii-ui.nvim/commit/8fcc1b90090d51fe141a751fa16d61a667f1de06))
* created component for conditional rendering ([c8664aa](https://github.com/rcasia/ascii-ui.nvim/commit/c8664aa13fe2956b106ad95d822944c5c7cca4e6))
* **cursor:** do not trigger ui event when a movement was caused by Cursor object ([730c636](https://github.com/rcasia/ascii-ui.nvim/commit/730c6367f2ba70beacc0e1e8bafed3c29fc71b2f))
* **cursor:** trigger ui events when there is a movement ([da82420](https://github.com/rcasia/ascii-ui.nvim/commit/da82420b50cde063b181f15a40efb327f55f602a))
* enable edits on buffer when focused on input ([1f62369](https://github.com/rcasia/ascii-ui.nvim/commit/1f62369033fc8ebe553fd64420aa23e934edf11b))
* expose ascii-ui hooks ([900ac8d](https://github.com/rcasia/ascii-ui.nvim/commit/900ac8db55f1078d90ecffa5736c2a1f0db6ddae))
* expose createComponent function to the public api ([656e1e1](https://github.com/rcasia/ascii-ui.nvim/commit/656e1e13e4d727048fb884dfd1defd1dd850257e))
* **for:** add example ([d24c8e9](https://github.com/rcasia/ascii-ui.nvim/commit/d24c8e9575ecdfb75a445acc2d9a5cbc1e2038fa))
* **for:** renders a component by a list of items tranformed ([9c4f03d](https://github.com/rcasia/ascii-ui.nvim/commit/9c4f03d865b0bdc75d7600af9c2642b728575065))
* **for:** renders a component by a list of props ([c26fdcd](https://github.com/rcasia/ascii-ui.nvim/commit/c26fdcd26207736ff753a2a7bc66d6f7a03b4d08))
* **for:** renders on list changes ([31c9a09](https://github.com/rcasia/ascii-ui.nvim/commit/31c9a09783076bddff2a3411aee6c7949c37184a))
* habilitate components to take props either as function or its simple type ([0f32075](https://github.com/rcasia/ascii-ui.nvim/commit/0f320755d7120ce1f0386907e21926b305e87000))
* **if:** render empty when condition is false and there is no fallback ([293d7de](https://github.com/rcasia/ascii-ui.nvim/commit/293d7de41c151cf5a88f19ce92498bf175bb84c3))
* **if:** renders fallback when condition is false ([9f46855](https://github.com/rcasia/ascii-ui.nvim/commit/9f4685501f039a972fb5e90e7f50016504e79e3e))
* init as lux project ([dc5576b](https://github.com/rcasia/ascii-ui.nvim/commit/dc5576bd94d54bcccb7e5e4e219667bc9647e0bc))
* **input:** input can have an initial value ([07c33c1](https://github.com/rcasia/ascii-ui.nvim/commit/07c33c17c5915271f00f1ef0ed159f02132cc7a6))
* move cursor to focusable when bufferlines count changes ([06c7061](https://github.com/rcasia/ascii-ui.nvim/commit/06c70610cb722896546d7b30f5443188a7b06694))
* render Layout component from DSL ([099c906](https://github.com/rcasia/ascii-ui.nvim/commit/099c90601fd4754ff66e4b95372d0ba3cdd0d97e))
* render multinested Layout from DSL ([f4f6335](https://github.com/rcasia/ascii-ui.nvim/commit/f4f63353ff82c3e164d0ed992abbeb6c44885b39))
* **row:** created row layout component ([66e7efe](https://github.com/rcasia/ascii-ui.nvim/commit/66e7efe938f534e654f8250419982e0fefe7177d))
* **row:** renders components respecting the empty space on the left ([67b5a71](https://github.com/rcasia/ascii-ui.nvim/commit/67b5a712e877810ab444c1c4805a407af7b59bd1))
* **row:** renders row with components having several lines in a row ([c9911e5](https://github.com/rcasia/ascii-ui.nvim/commit/c9911e599c893a0af677e2a56c200eeb99f8b35f))
* **row:** renders row with respecting components spacing ([c9b5861](https://github.com/rcasia/ascii-ui.nvim/commit/c9b58617a46d4a42575a870f100f8c46d3e2a394))
* **row:** renders row with several components in a row ([96e60d4](https://github.com/rcasia/ascii-ui.nvim/commit/96e60d48a397289967cb02f62e3f8dca23386862))
* **useEffect:** does not invoke function when a non observed value changes ([98a4f2f](https://github.com/rcasia/ascii-ui.nvim/commit/98a4f2f0f5bd6e12a1dce7f0e0df0e5646aaa121))
* **useEffect:** invokes function everytime observed values change ([41efade](https://github.com/rcasia/ascii-ui.nvim/commit/41efade1ff8417e2fb25d556fe15b1991e82c739))
* **window:** resize to match buffer ([c8bda07](https://github.com/rcasia/ascii-ui.nvim/commit/c8bda07d0080ec483b673c73285d34226506fcf7))


### Bug Fixes

* avoid sharing state between components with same props ([ad86a0c](https://github.com/rcasia/ascii-ui.nvim/commit/ad86a0c044cfdbafe49da0caa852238d78e18a5c))
* **buffer:** make col 0-indexed ([de11905](https://github.com/rcasia/ascii-ui.nvim/commit/de11905c77029c48a1b64a49e4d208927e249073))
* logger formats only when varargs ([ba22e7e](https://github.com/rcasia/ascii-ui.nvim/commit/ba22e7e941f08c13973d2a88df3d12067de79e66))
* **win:** adjust scroll when lines are added to the buffer ([d817a87](https://github.com/rcasia/ascii-ui.nvim/commit/d817a877217d006c3fa27105aa81590c91ea877d))

## [0.1.0](https://github.com/rcasia/ascii-ui.nvim/compare/v0.0.1...v0.1.0) (2025-05-09)


### Features

* add logo ([80560b5](https://github.com/rcasia/ascii-ui.nvim/commit/80560b54ca3ff7782f872071709df2c691ff030d))
* add simple logger ([b5319d8](https://github.com/rcasia/ascii-ui.nvim/commit/b5319d8130cddd28b833739ba80ba48b5d9cc793))
* **button:** add on_press function ([41ad7f0](https://github.com/rcasia/ascii-ui.nvim/commit/41ad7f0d8ff34b1ac0b3f2b05501d5dc7e15a3bb))
* **button:** better buttom colors ([ebf45f4](https://github.com/rcasia/ascii-ui.nvim/commit/ebf45f4287d487afec42c340200fc1694fc784be))
* **button:** create new button component ([f00fc30](https://github.com/rcasia/ascii-ui.nvim/commit/f00fc30f5ce8af6b1ed408acb1b51b05948a2b39))
* **button:** expose button component ([3ed2f5e](https://github.com/rcasia/ascii-ui.nvim/commit/3ed2f5e00865dd9e369351a095f2955638550ca2))
* **button:** make it a focusable element ([1887660](https://github.com/rcasia/ascii-ui.nvim/commit/188766019b8a6691e859227499835c2a3b82f847))
* **button:** render button with colored background ([48fa65b](https://github.com/rcasia/ascii-ui.nvim/commit/48fa65b3361b18edce3dbddcb47dbf0b4745543b))
* **component:** removes on_change callback when it fails ([927cc22](https://github.com/rcasia/ascii-ui.nvim/commit/927cc2243942466db7a5ae0e207a7dc3441192ed))
* ensure the log dir exists ([71c77fb](https://github.com/rcasia/ascii-ui.nvim/commit/71c77fb9985594b48476e45b8d0a3b544cfef565))
* expose public components through api ([5121b0b](https://github.com/rcasia/ascii-ui.nvim/commit/5121b0b4bddef99064a1f2354672476bd2fa70b4))
* **options:** accepts on_select function on creation ([d1080bc](https://github.com/rcasia/ascii-ui.nvim/commit/d1080bc228e7919ed87f86e4394fd52454e45f6b))
* **options:** add on_select method for easier user interaction handling ([466cc55](https://github.com/rcasia/ascii-ui.nvim/commit/466cc55fa820c20b6b8a99251a4f108237cea85b))
* **paragraph:** create paragraph component ([e6b4739](https://github.com/rcasia/ascii-ui.nvim/commit/e6b47391b1268e4e5f359df9c02d08ed3a59cb35))
* **slider:** render slider with title ([89b42f2](https://github.com/rcasia/ascii-ui.nvim/commit/89b42f277111cc8b011bf571ad82d4f5d99559cf))
* **state:** introduce global state handler ([8b8efd9](https://github.com/rcasia/ascii-ui.nvim/commit/8b8efd98fa03f0cdc0a37326586514f9b7a33fe8))


### Bug Fixes

* calculate next position from the next column in the same line ([d4c6996](https://github.com/rcasia/ascii-ui.nvim/commit/d4c6996e14bd07331413aa63c4a82c99adad67aa))
* **component:** pass state change params ([b862296](https://github.com/rcasia/ascii-ui.nvim/commit/b86229618378c0930b55b2ca8a82c2fcbba67f11))
* **docstring:** ignore diagnostic for inject-field ([7de36ce](https://github.com/rcasia/ascii-ui.nvim/commit/7de36ce2d349af905e965e0e35a6cc457cfa7210))
* **layout:** rename subscribe -&gt; on_change ([270720d](https://github.com/rcasia/ascii-ui.nvim/commit/270720d9aacf469110a9edff72db58dbefcaa1e3))
* move just one focusable down at a time ([b0fdfc3](https://github.com/rcasia/ascii-ui.nvim/commit/b0fdfc3c9efb2dff5033e1e1238ef89775d831af))
* write logs into the plugin data folder ([79c7353](https://github.com/rcasia/ascii-ui.nvim/commit/79c73532d11d695f454b75e4eacd0df191f3a3a0))

## [0.0.1](https://github.com/rcasia/ascii-ui.nvim/compare/v0.0.0...v0.0.1) (2025-04-03)


### Features

* **buffer:** calculate height from the count of lines ([a9f8730](https://github.com/rcasia/ascii-ui.nvim/commit/a9f873065ff53287f588939e1807aaaaf499c8c0))
* **buffer:** calculate width of a buffer by its longest line ([dfb35bc](https://github.com/rcasia/ascii-ui.nvim/commit/dfb35bcb31e48b40f18fba38160c151d1edad718))
* **buffer:** find last focusable element ([d344949](https://github.com/rcasia/ascii-ui.nvim/commit/d344949ff5df89ff20968fe91ff728e080e24730))
* **buffer:** find last focusable even if in the same line ([ac4cf6b](https://github.com/rcasia/ascii-ui.nvim/commit/ac4cf6bf1246930778b94af7f0837d95817c48a9))
* **buffer:** find position when iterating through colored elements in buffer ([927951a](https://github.com/rcasia/ascii-ui.nvim/commit/927951a3184723d04a3261008eb516c42f891a5f))
* **buffer:** finds next focusable from default position 1,1 ([60f73ed](https://github.com/rcasia/ascii-ui.nvim/commit/60f73ed775cf3557241a5e47884448cb3b2d0090))
* **buffer:** finds next focusable in next lines ([9d3740f](https://github.com/rcasia/ascii-ui.nvim/commit/9d3740f4a2cbca28d43ad2f61ffa6f5dfd2756f4))
* **buffer:** finds next focusable returns nil when not found ([45104c8](https://github.com/rcasia/ascii-ui.nvim/commit/45104c85010db85273c620596a92633dd8257bc7))
* **buffer:** finds position of the next focusable ([e411729](https://github.com/rcasia/ascii-ui.nvim/commit/e411729bf0d3e423c5d1622f5673cc3636be7341))
* **buffer:** implement Buffer:iter_colored_elements() ([31ef5b7](https://github.com/rcasia/ascii-ui.nvim/commit/31ef5b7832ca9e05031e5cee8f461f5680381aa4))
* **bufferline:** implement to_string function ([ee65110](https://github.com/rcasia/ascii-ui.nvim/commit/ee65110bba95bf34291b2f21e27592879e204b8b))
* **buffer:** returns same input position when not found ([481713b](https://github.com/rcasia/ascii-ui.nvim/commit/481713bb0e6d48b5092f8cf21cece494effd7f80))
* close virtual window when nvim window is closed ([7e919ce](https://github.com/rcasia/ascii-ui.nvim/commit/7e919ced84514732136a9b3328209f2a776d93a1))
* **component:** removes subscriptions on destroy ([0990efe](https://github.com/rcasia/ascii-ui.nvim/commit/0990efe3b9e2a51d8596d67d10761ce6dffcaad9))
* create cursor move up and down interaction types ([3a0cd35](https://github.com/rcasia/ascii-ui.nvim/commit/3a0cd35fbf83f5b67a1aaf7866d4d8a41b4eda55))
* **element:** accept table of props for instantiation ([5125e56](https://github.com/rcasia/ascii-ui.nvim/commit/5125e56f0435d2271567a39c04b60146a54d65d4))
* **element:** accept table of props for instantiation ([7c87561](https://github.com/rcasia/ascii-ui.nvim/commit/7c875611b2f505987a27f3c6009164cd49592216))
* expose layout api ([89ad25b](https://github.com/rcasia/ascii-ui.nvim/commit/89ad25bd8b3cb30e4adb4fe32bfb5a9dfc093a59))
* initialize keymaps on mount ([0d13a64](https://github.com/rcasia/ascii-ui.nvim/commit/0d13a64c78736317687f1f3e29d9442e610eac8b))
* **interaction:** do nothing when buffer is not found ([d7cfea9](https://github.com/rcasia/ascii-ui.nvim/commit/d7cfea91e07b8110c226db35868c1c787a772794))
* **interactions:** use the nvim buffer id ([91aae3f](https://github.com/rcasia/ascii-ui.nvim/commit/91aae3f3f11724d522b069d9bbd016996834f9b0))
* jump lines right ([f04026a](https://github.com/rcasia/ascii-ui.nvim/commit/f04026a6f4d5fe90f0f043c6939543b23a1d2bb3))
* jump only to focusable lines ([ede9d12](https://github.com/rcasia/ascii-ui.nvim/commit/ede9d128cbac11da06ddd3c1e1f7855844077444))
* **layout:** subscribe and detroy recursively ([ee65bc6](https://github.com/rcasia/ascii-ui.nvim/commit/ee65bc6f86d66d25b9c6e4040b58de61a24116c8))
* listen to WinClosed autocommand to destroy components and interactions ([18dcb27](https://github.com/rcasia/ascii-ui.nvim/commit/18dcb27b09bbcf4c03b3b6a6ce754d29bebd1a61))
* move among focusables left and right ([7f31326](https://github.com/rcasia/ascii-ui.nvim/commit/7f3132609ba52eb2792be3395a95dc8e797ee2f4))
* open floating window in the center by default ([9f8d6b3](https://github.com/rcasia/ascii-ui.nvim/commit/9f8d6b3c9da37947365d0d5fc1633085a612049b))
* **options:** option items are focusable and title is not ([a79b05a](https://github.com/rcasia/ascii-ui.nvim/commit/a79b05a68fc652f162f8943d4fdc4b4e076f233b))
* **options:** renders element with highlight ([c32651c](https://github.com/rcasia/ascii-ui.nvim/commit/c32651cb74a944976be98e6480729d8066b64188))
* **options:** renders highlight only on selected option ([816dc41](https://github.com/rcasia/ascii-ui.nvim/commit/816dc419da72f370e01af721845b77011e80be87))
* skip non focusable elements on cursor move down ([d8981ab](https://github.com/rcasia/ascii-ui.nvim/commit/d8981abf4cef8170602f71baa0e3bbf881ba9a63))
* slider moves on select ([f0e7f1b](https://github.com/rcasia/ascii-ui.nvim/commit/f0e7f1bfd1dd3be8e992272bca75357c2bdaaab7))
* slider moves right and left on interaction ([24d7853](https://github.com/rcasia/ascii-ui.nvim/commit/24d7853db0e1ffc25660992a7db628d9fc0adcce))
* **slider:** add slider thumb to configuration ([96b53de](https://github.com/rcasia/ascii-ui.nvim/commit/96b53de8d7d9c31c522d1955d4201f92f08b725a))
* **slider:** create Slider component ([a23ce1f](https://github.com/rcasia/ascii-ui.nvim/commit/a23ce1fed718a82b9d9bd367bdfaca1ff7406678))
* **slider:** create with a given default value ([88aaefd](https://github.com/rcasia/ascii-ui.nvim/commit/88aaefdf1595716dc8abef40682122963a6fa994))
* **slider:** do not go above 100 ([36eb4d4](https://github.com/rcasia/ascii-ui.nvim/commit/36eb4d48462936831e4dea85daff374b54dbf7d6))
* **slider:** do not go below zero ([ab5168e](https://github.com/rcasia/ascii-ui.nvim/commit/ab5168e8b6b6894d3ed6aec0156694acf457de6c))
* **slider:** made slider thumb focusable and slider line non focusable ([9ddf185](https://github.com/rcasia/ascii-ui.nvim/commit/9ddf18531434863a5df7c88562889edd1a0626c4))
* **slider:** move right and left by ten ([cca81a2](https://github.com/rcasia/ascii-ui.nvim/commit/cca81a2dd8640de029cf7a9631d6b75f5d59bd09))
* **slider:** render percentage value ([c48e412](https://github.com/rcasia/ascii-ui.nvim/commit/c48e41269cffc2b4762acd099530e691b5d00109))
* **slider:** render when has different values ([33947d4](https://github.com/rcasia/ascii-ui.nvim/commit/33947d4dfa0f2491d078d01008a4b33a297f19bd))
* **slider:** render when value is at 100 ([876e298](https://github.com/rcasia/ascii-ui.nvim/commit/876e298c61838e7cc5efe1acc6468d599a25d316))
* **window:** open window with the size of the buffer ([24edf8c](https://github.com/rcasia/ascii-ui.nvim/commit/24edf8c37e098a4cdc5d9525ae23365df5d623ab))
* **window:** print the element color in window ([f4a9558](https://github.com/rcasia/ascii-ui.nvim/commit/f4a9558d5731ff35931bfda80ee8787dffad445c))


### Bug Fixes

* **buffer:** find next focusables to the right in the same line ([6ec60d2](https://github.com/rcasia/ascii-ui.nvim/commit/6ec60d2f5755d172f0ef601b4a7c91bf8ad22c58))
* **slider:** separate 10% and 0% ([3ebabca](https://github.com/rcasia/ascii-ui.nvim/commit/3ebabcac547cab9260b6053b298392c882f802b3))
* unsubcribe from vim.on_key ([50bb9af](https://github.com/rcasia/ascii-ui.nvim/commit/50bb9afdbee6ad9182055c7449deb01892e48501))
* update focusable points when buffer changes ([b3bbf1b](https://github.com/rcasia/ascii-ui.nvim/commit/b3bbf1b845f6bc7492a6f186150398e8b93debd9))


### Miscellaneous Chores

* release 0.0.1 ([75a085f](https://github.com/rcasia/ascii-ui.nvim/commit/75a085f58f60bbeabf9b19dabe3af23074e8da4e))

## 0.0.0 (2025-03-22)


### Features

* add __name to every extended component ([53c9e76](https://github.com/rcasia/ascii-ui.nvim/commit/53c9e76b123247419d6c187403a35b78d2e2f310))
* add box that admits plain text ([54cf1f7](https://github.com/rcasia/ascii-ui.nvim/commit/54cf1f73b880c78fe7a99b47d0512abd6098d59b))
* add buffer module ([1875b1d](https://github.com/rcasia/ascii-ui.nvim/commit/1875b1db8cd9dad6bc7fe561d7659319351bcf90))
* add clear_subscriptions function ([1b88085](https://github.com/rcasia/ascii-ui.nvim/commit/1b880851262b72ae9df14cf7d941cb72670eb260))
* add component that runs subscriptions on state changes ([f24d502](https://github.com/rcasia/ascii-ui.nvim/commit/f24d50251fec80729f763d4f9517b1513a308cde))
* add configuted characters to dynamic box text rendering ([42726aa](https://github.com/rcasia/ascii-ui.nvim/commit/42726aaef5c810f5f6183c80022b229bdd19c7d1))
* add default window size ([d56c231](https://github.com/rcasia/ascii-ui.nvim/commit/d56c231bd9b4c473690752bca1a893b62a3a7b03))
* add element module ([79ec762](https://github.com/rcasia/ascii-ui.nvim/commit/79ec76211150d94a5e4b7c6b5ed21143062a1cb1))
* add height to box component ([395f815](https://github.com/rcasia/ascii-ui.nvim/commit/395f8155d328ba817a777d784780bbeea54ba303))
* add label to checkbox ([22729f5](https://github.com/rcasia/ascii-ui.nvim/commit/22729f5e3ec4daccecc8b560f003c68a5b077ff1))
* add one line space between component in layout ([2eafd9c](https://github.com/rcasia/ascii-ui.nvim/commit/2eafd9c3ca1b9ef914ef0dea7b2946987991e088))
* add props to extesible component ([5ea3bf1](https://github.com/rcasia/ascii-ui.nvim/commit/5ea3bf18b6c74cc2931864baf2c0addcbc9fe622))
* add renderer that renders checkbox ([0c7653d](https://github.com/rcasia/ascii-ui.nvim/commit/0c7653d3bb07a00c2ace1b62ece9192b913fe423))
* add singleton for user interactions ([b177798](https://github.com/rcasia/ascii-ui.nvim/commit/b177798bc2c4f877bb2f51b560ac237c574e1e6e))
* add support for different user interactions ([8247734](https://github.com/rcasia/ascii-ui.nvim/commit/8247734912f3b33aa253722a9a0c6e4c7fbc0f2a))
* add text input ([365e16f](https://github.com/rcasia/ascii-ui.nvim/commit/365e16f12bafde615022b5209078d0cbdefb48f6))
* add window ([3fd315a](https://github.com/rcasia/ascii-ui.nvim/commit/3fd315a30a00c03464534d9c4835219e9d86b668))
* added renderer config for characters to be used ([99bbca6](https://github.com/rcasia/ascii-ui.nvim/commit/99bbca6ef7aa290ceef06505f59f650a83592e01))
* apply bg and fg colors on ui ([62ae67b](https://github.com/rcasia/ascii-ui.nvim/commit/62ae67b9b717e11cad8de51afd59d983204e1164))
* ascii renderer returns buffer object ([399f40d](https://github.com/rcasia/ascii-ui.nvim/commit/399f40d43e0f8cf3693672de8db2c3860044b72e))
* box also renders into buffer object ([5592467](https://github.com/rcasia/ascii-ui.nvim/commit/55924672900406e76aa02cb1706f6aae8f500de5))
* bufferline accepts array of elements ([3fbf1c7](https://github.com/rcasia/ascii-ui.nvim/commit/3fbf1c77f66743eb822d9de98b5b355bba66a09c))
* center vertically the text in the box ([34fa435](https://github.com/rcasia/ascii-ui.nvim/commit/34fa435ca8d5c70430b89cfcd2dbc9d1af960577))
* check box provides bufferlines to renderer ([4e88201](https://github.com/rcasia/ascii-ui.nvim/commit/4e88201d7e9af7477801c9f752b13dc03fccb91c))
* checkbox can be initialized to true ([f8d4f7e](https://github.com/rcasia/ascii-ui.nvim/commit/f8d4f7e67ea85f58cb1741bf751915431320e948))
* checkbox renders ([6237f84](https://github.com/rcasia/ascii-ui.nvim/commit/6237f84704d2717cc00555a42d3252a86794ea34))
* component is extensible ([3753434](https://github.com/rcasia/ascii-ui.nvim/commit/3753434ebee9dcb3a1467ec6be4fb50046ecc072))
* create buffer and bufferline ([7562c66](https://github.com/rcasia/ascii-ui.nvim/commit/7562c66ec0c6e22aaa5dafd44e7edaf1c8c00791))
* create switch component ([84c5db6](https://github.com/rcasia/ascii-ui.nvim/commit/84c5db62fc9b099388422445b32d6b5cb0978d28))
* created checkbox component ([41e6757](https://github.com/rcasia/ascii-ui.nvim/commit/41e6757ac6586ad952d190f54eb91d72f1ebd37d))
* find element by id ([f6367c2](https://github.com/rcasia/ascii-ui.nvim/commit/f6367c296b28e6ed1822589b4a7f2d0fa976be69))
* find element by position in buffer ([5885031](https://github.com/rcasia/ascii-ui.nvim/commit/58850313c71d59ae4891996637ad6afc31d58c4b))
* find focusable element when is in a later line ([f6eeeee](https://github.com/rcasia/ascii-ui.nvim/commit/f6eeeeed3508db6762717d12bd92ed48051853c0))
* finds focusable element ([8e05d71](https://github.com/rcasia/ascii-ui.nvim/commit/8e05d7135cdb5c8faac1580bff7befb4332c7479))
* finds focusable element having different elements in bufferline ([60287be](https://github.com/rcasia/ascii-ui.nvim/commit/60287beacae9e06d45112c3f08baf196c3462501))
* generalize main function ([0757d64](https://github.com/rcasia/ascii-ui.nvim/commit/0757d640c5d4bab68ade601ea84e76508949cec6))
* implemented on_select for options component ([1a42914](https://github.com/rcasia/ascii-ui.nvim/commit/1a429144959927cacd716e98bf4e6e2adf43039f))
* it render box with dynamic text ([266658c](https://github.com/rcasia/ascii-ui.nvim/commit/266658ce308c6b1d718da0fa29e8f46337ec577b))
* it renders a box width defined width ([383d329](https://github.com/rcasia/ascii-ui.nvim/commit/383d329c3575a8a345eaa5f4b7ae1f00c04ac555))
* iterate throught the focusables ([3dd9875](https://github.com/rcasia/ascii-ui.nvim/commit/3dd98758f8ff7c17a5fc0ca99337cecdf62b2956))
* layout renders vertical by default ([d3897cb](https://github.com/rcasia/ascii-ui.nvim/commit/d3897cb9b462251d797443102e9dd7cce76df73e))
* main render function accepts every component ([3fb60c1](https://github.com/rcasia/ascii-ui.nvim/commit/3fb60c1d22bdd9c3b1d37917e3dcebdcba4f819e))
* make the buffer inmodifiable ([167052f](https://github.com/rcasia/ascii-ui.nvim/commit/167052f17d0a255130ad10c3ff9447b31aa1afe0))
* make window round ([84e11ea](https://github.com/rcasia/ascii-ui.nvim/commit/84e11ea7a3909f0ee8672ffa9c34323a0876bfd5))
* map select interaction to a key ([0b0f1dc](https://github.com/rcasia/ascii-ui.nvim/commit/0b0f1dc837db23c2105ea28184360165ed06e460))
* options component accepts title ([8a6e14c](https://github.com/rcasia/ascii-ui.nvim/commit/8a6e14c12b2ff515c8b47569c042c87cae0a7d95))
* options component renders ([977bfbc](https://github.com/rcasia/ascii-ui.nvim/commit/977bfbce6efdc5cade58bc9566dd8860bbbe18cd))
* options component selects by index ([d4fe8b6](https://github.com/rcasia/ascii-ui.nvim/commit/d4fe8b659abbeb62977d0baa576dbc97d9692ba9))
* render box component with public api ([9155912](https://github.com/rcasia/ascii-ui.nvim/commit/9155912d946028c91dd3d96a733d0551e20ab9f7))
* render layout ([bdb0df3](https://github.com/rcasia/ascii-ui.nvim/commit/bdb0df3389226707deee1f2213cc19c48e82b2c4))
* renders and updates components inside layout ([c572d4c](https://github.com/rcasia/ascii-ui.nvim/commit/c572d4ca73e063236bba7e5e69d14b0a1da635f2))
* renders box with hello text ([11c70ed](https://github.com/rcasia/ascii-ui.nvim/commit/11c70ed8c2fbef7fe23ae6bd2428755008aa1bd0))
* renders simple box ([f38006b](https://github.com/rcasia/ascii-ui.nvim/commit/f38006bd1acf99b053db44c98e26a585559fbaaa))
* returns position when looking for focusable ([8fb940b](https://github.com/rcasia/ascii-ui.nvim/commit/8fb940bab0f0db064d546c9bd4611f2612249e7e))
* say hello world ([9813b6a](https://github.com/rcasia/ascii-ui.nvim/commit/9813b6aa8d3e4862464d9684e3438292b1006961))
* subcribe to custom component self state changes ([882bc5d](https://github.com/rcasia/ascii-ui.nvim/commit/882bc5dec2a283afa7ec43dd139b0f7202eca533))
* subscribes to subsequent changes ([3696778](https://github.com/rcasia/ascii-ui.nvim/commit/369677893e4699cf3fd020c9959912dc6c1c429d))
* switch is converted to options component ([08c46e2](https://github.com/rcasia/ascii-ui.nvim/commit/08c46e27809427fa04e74aafa77a3807250c8546))
* switch selects next option ([dd9d05c](https://github.com/rcasia/ascii-ui.nvim/commit/dd9d05c26b7e9fcdaf577b7d1dcc4b17e3c1fdcb))
* throws error when trying to instantiate box with less than 3 of height ([bb31fec](https://github.com/rcasia/ascii-ui.nvim/commit/bb31fec3f6b4820b653a54474de9521509d9e531))
* user can interact with element ([a694ce5](https://github.com/rcasia/ascii-ui.nvim/commit/a694ce5b1a7a78df5971b1415377512fb54f0c4c))
* when element is not found it does nothing ([ecf33e4](https://github.com/rcasia/ascii-ui.nvim/commit/ecf33e4d9e5b5491f262a918040e250af64d4eb5))
* window shows the render ([1e4da92](https://github.com/rcasia/ascii-ui.nvim/commit/1e4da92767dd740e65ab17d59de7c45e05d41b7d))
* **wip:** expose api to render box in intervals ([adaf4de](https://github.com/rcasia/ascii-ui.nvim/commit/adaf4de0f07c38ae748093d8dfc7448cbcda5726))
* wrap render call in vim.schedule ([b0dbb8c](https://github.com/rcasia/ascii-ui.nvim/commit/b0dbb8ce40a4652500697c92598e04a8a0fb7880))


### Bug Fixes

* **build:** use bash command to be compatible with windows ([676cb2d](https://github.com/rcasia/ascii-ui.nvim/commit/676cb2da0129fa496cc1f5205f027031139517eb))
* give window a list of strings ([0e1d7f9](https://github.com/rcasia/ascii-ui.nvim/commit/0e1d7f9cfb56637de1081895544d3fa9992be001))
* recognize child component methods ([be1830d](https://github.com/rcasia/ascii-ui.nvim/commit/be1830d94ea0b4e7f246502c60ff1f4713dab145))


### Miscellaneous Chores

* release 0.0.0 ([40e5c2f](https://github.com/rcasia/ascii-ui.nvim/commit/40e5c2f5f2e065c9520fd6f841d8f57ef8a536cf))
