xquery version "3.0";

let $docs := collection("?select=*.xml")

(: Calculate the total occurrences of each word in the corpus :)
let $word-frequencies :=
  for $doc in $docs
  for $w in $doc//w
  let $word := lower-case(normalize-space(string($w)))
  group by $word
  return <word frequency="{count($w)}">{$word}</word>

(: Gather pairs of 'has' and its successor words :)
let $pairs :=
  for $doc in $docs
  for $w in $doc//w
  where lower-case(normalize-space(string($w))) = "has"
  let $next-word := lower-case(normalize-space(string($w/following-sibling::w[1])))
  return
    <pair>
      <current>{string($w)}</current>
      <next>{$next-word}</next>
    </pair>

(: Generate unique pairs with their frequency and calculate the probability :)
let $unique-pairs :=
  for $pair in $pairs
  let $current := $pair/current
  let $next := $pair/next
  group by $current, $next
  let $frequency := count($pair)
  let $total-occurrences := 
    (for $freq in $word-frequencies
     where $freq = $next
     return $freq/@frequency)
  let $probability := $frequency div number($total-occurrences)
  order by $frequency descending
  return
    <unique-pair>
      <current>{$current}</current>
      <next>{$next}</next>
      <frequency>{$frequency}</frequency>
      <probability>{$probability}</probability>
    </unique-pair>
    
(: Select the top 20 results :)
let $top20 := subsequence($unique-pairs, 1, 20)

(: Output the result as an HTML table :)
return
<html>
  <body>
    <table border="1">
      <tr>
        <th>Target</th>
        <th>Successor</th>
        <th>Probability</th>
      </tr>
      {
        for $up in $top20
        return
          <tr>
            <td>{string($up/current)}</td>
            <td>{string($up/next)}</td>
            <td>{format-number($up/probability, '0.##')}</td>
          </tr>
      }
    </table>
  </body>
</html>