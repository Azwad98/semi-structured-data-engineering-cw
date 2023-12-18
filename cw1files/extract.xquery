xquery version "3.0";

(: Load the collection of XML files from the 'cw1files' directory :)
let $docs := collection("?select=*.xml")

(: Construct the HTML table :)
return
<html>
  <body>
    <table border="1">
      <tr>
        <th>Target</th>
        <th>Successor</th>
      </tr>
      {
        for $doc in $docs
        for $w in $doc//w
        where lower-case(normalize-space(string($w))) = "has"
        let $next := $w/following-sibling::w[1]
        return
          <tr>
            <td>{string($w)}</td>
            <td>{string($next)}</td>
          </tr>
      }
    </table>
  </body>
</html>
