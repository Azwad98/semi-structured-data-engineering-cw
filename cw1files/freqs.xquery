xquery version "3.0";

let $docs := collection("?select=*.xml")

let $pairs :=
  for $doc in $docs
  for $w in $doc//w
  where lower-case(normalize-space(string($w))) = "has"
  let $next := lower-case(normalize-space(string($w/following-sibling::w[1])))
  return
    <pair>
      <current>{string($w)}</current>
      <next>{string($next)}</next>
    </pair>

let $unique-pairs :=
  for $pair in $pairs
  group by $current := $pair/current, $next := $pair/next
  let $frequency := count($pair)
  order by $frequency descending
  return
    <unique-pair>
      <current>{$current}</current>
      <next>{$next}</next>
      <frequency>{$frequency}</frequency>
    </unique-pair>

return
<html>
  <body>
    <table border="1">
      <tr>
        <th>Target</th>
        <th>Successor</th>
        <th>Frequency</th>
      </tr>
      {
        for $up in $unique-pairs
        return
          <tr>
            <td>{string($up/current)}</td>
            <td>{string($up/next)}</td>
            <td>{string($up/frequency)}</td>
          </tr>
      }
    </table>
  </body>
</html>
