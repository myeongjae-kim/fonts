# Fonts

- [BadScript](https://hrzon.github.io/fonts/BadScript/)
- [Inconsolata](https://hrzon.github.io/fonts/Inconsolata/)
- [Iropke Batang](https://hrzon.github.io/fonts/IropkeBatangMSubset/)
- [Source Sans Pro](https://hrzon.github.io/fonts/SourceSansPro/)

웹 개발시에 자주 쓰이는 웹폰트를 모아놓았습니다. woff2, woff와 ttf 포맷의 글씨체, 그리고 글씨체를 base64로 인코딩한 css파일을 제공합니다.

글씨체가 따르는 라이선스들은 개별 글씨체들의 디렉토리 안에 포함되어 있습니다.

한글 서브셋 생성에 쓰인 스크립트와 글리프들은 다음과 같은 곳에서 참조했습니다.

- 스크립트: <https://github.com/spoqa/spoqa-han-sans/blob/master/build_subset>
- 글리프: <https://github.com/spoqa/spoqa-han-sans/blob/master/Subset/SpoqaHanSans/glyphs.txt>

woff와 woff2 변환은 다음과 같은 프로그램을 사용했습니다.

- ttf2woff: <https://www.npmjs.com/package/ttf2woff>
- woff2: <https://github.com/google/woff2>

## 웹 폰트를 로컬 스토리지에 저장하기

출처: [웹 폰트를 로컬 스토리지에 저장하는 기법 - 캐시 안정성 증가, 글꼴 깜빡임 현상 제거](https://mytory.net/2016/06/15/webfont-best-practice.html)

사용하고 싶은 웹 폰트들의 css를 cat으로 연결한 뒤 자바스크립트를 통해 적용합니다.

예를 들어 BadScript, Inconsolata, 이롭게 바탕, Source Sans Pro Light를 사용하고 싶다면,

```bash
cat ./BadScript/badscript-normal-400-woff2.css ./Inconsolata/inconsolata-normal-400-woff2.css ./IropkeBatangMSubset/iropke-batang-m-subset-woff2.css ./SourceSansPro/source-sans-pro-italic-300-woff2.css > fonts-woff2.css

cat ./BadScript/badscript-normal-400-woff.css ./Inconsolata/inconsolata-normal-400-woff.css ./IropkeBatangMSubset/iropke-batang-m-subset-woff.css ./SourceSansPro/source-sans-pro-italic-300-woff.css > fonts-woff.css
```

이렇게 `fonts-woff2.css`와` fonts-woff.css`파일을 생성한 후 아래 자바스크립트 코드를 추가하면 됩니다.

```javascript
// https://mytory.net/2016/06/15/webfont-best-practice.html 참고
(function() {
  (async () => {
    "use strict";
    // 스매싱 매거진의 '지연된 웹폰트 불러오기' javascript를 안형우가 수정한 것.
    // https://gist.github.com/hdragomir/8f00ce2581795fd7b1b7

    // 한 번 캐시하면 css 파일은 클라이언트 측에 저장한다.
    // 아래 woffPath 가 바뀌면 그 때 다시 받는다.
    // woff base64를 내장한 css
    var woffPath = './fonts-woff.css';
    // woff2 base64를 내장한 css
    var woff2Path = './fonts-woff2.css';

    // 간단한 이벤트 핸들러 함수
    function on(el, ev, callback) {
      if (el.addEventListener) {
        el.addEventListener(ev, callback, false);
      } else if (el.attachEvent) {
        el.attachEvent("on" + ev, callback);
      }
    }

    // localStorage 에 글꼴이 저장돼 있거나, 네이티브 브라우저 캐시를 이용해 저장했다면...
    if (
      (window.localStorage && localStorage.fontCache)
      || document.cookie.indexOf('fontCache') > -1
    ) {
      // 캐시된 버전을 사용한다.
      injectFontsStylesheet();
    } else {
      // 캐시된 버전이 없으면 페이지 로딩을 막지 않고 기다렸다가
      // 페이지가 전부 load 되면 웹폰트를 다운로드한다.
      on(window, "load", injectFontsStylesheet);
    }

    /**
     * css 파일이 브라우저에 저장됐는지 확인하는 함수.
     * @param href
     * @returns {Storage|string|*|boolean}
     */
    function isFileCached(href) {
      return (
        window.localStorage
        && localStorage.fontCache
        && (localStorage.fontCacheFile === href)
      );
    }

    /**
     * 실제 css 내용을 넣는 함수
     */
    function injectFontsStylesheet() {

      var supportsWoff2 = (function (win) {
        if (!("FontFace" in win)) {
          return false;
        }

        var f = new FontFace('t', 'url( "data:application/font-woff2;base64,d09GMgABAAAAAADcAAoAAAAAAggAAACWAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAABk4ALAoUNAE2AiQDCAsGAAQgBSAHIBtvAcieB3aD8wURQ+TZazbRE9HvF5vde4KCYGhiCgq/NKPF0i6UIsZynbP+Xi9Ng+XLbNlmNz/xIBBqq61FIQRJhC/+QA/08PJQJ3sK5TZFMlWzC/iK5GUN40psgqvxwBjBOg6JUSJ7ewyKE2AAaXZrfUB4v+hze37ugJ9d+DeYqiDwVgCawviwVFGnuttkLqIMGivmDg" ) format( "woff2" )', {});
        f.load()['catch'](function () { });

        return f.status == 'loading' || f.status == 'loaded';
      })(window);

      // woff 지원 여부는 체크하지 않는다. 안드로이드 4.4 미만, IE9 미만은 woff를 지원하지 않는데, 워낙 소수라 일단 디텍트 코드를 넣지 않았다.
      var fontPath = woffPath;
      if (supportsWoff2) {
        fontPath = woff2Path;
      }

      if (isFileCached(fontPath)) {
        // 로컬 스토리지에 캐시한 버전이 있다면 그걸 <head>에 박는다.
        injectRawStyle(localStorage.fontCache);
      } else {
        // 아니면, ajax 로 불러온다.
        // jQuery 만 쓴 분들은 생소하겠지만, 이게 plain js로 구현한 ajax 다.
        var xhr = new XMLHttpRequest();
        xhr.open("GET", fontPath, true);

        // ajax 에서 addEventListener 나 attachEvent 를 지원하지 않는 IE8을 위한 조치
        xhr.onreadystatechange = function () {
          if (xhr.readyState === 4) {
            if (xhr.responseText[0] === '<') {
              return;
            }

            // ajax 로 받은 css 내용을 <head>에 박는다.
            injectRawStyle(xhr.responseText);
            // 그리고 css 내용을 로컬 스토리지에 집어 넣어 나중에도 쓸 수 있게 한다.
            // 기존에 저장된 것이 있다면 덮어쓴다는 점을 알아 둬라.
            localStorage.fontCache = xhr.responseText;
            localStorage.fontCacheFile = fontPath;
          }
        };
        xhr.send();
      }
    }

    /**
     * css 텍스트를 <head>에 집어넣는 간단한 함수
     * @param text
     */
    function injectRawStyle(text) {
      var style = document.createElement('style');
      // style.innerHTML 을 지원하지 않는 IE8을 위한 조치
      style.setAttribute("type", "text/css");
      if (style.styleSheet) {
        style.styleSheet.cssText = text;
      } else {
        style.innerHTML = text;
      }
      document.getElementsByTagName('head')[0].appendChild(style);
    }
  })();
}());

```



## 참고

[웹 폰트를 로컬 스토리지에 저장하는 기법 - 캐시 안정성 증가, 글꼴 깜빡임 현상 제거](https://mytory.net/2016/06/15/webfont-best-practice.html)

[스포카 한 산스 웹폰트로 사용하기](https://spoqa.github.io/2017/02/15/using-shs-as-webfonts.html)
