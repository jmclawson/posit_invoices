#set table( 
   inset: 6pt, 
   stroke: none,
 ) 
 
#let table-header(..headers) = {
  table.header(..headers.pos().map(it => {
    set text(weight: "bold")
    it
  }))
}

#set text(font: ("serif") , size: 11pt);

#let invoiced(
  sender_name: none,
  sender_address1: none,
  sender_address2: none,
  sender_phone: none,
  sender_email: none,
  recipient_name: none,
  recipient_address1: none,
  recipient_address2: none,
  recipient_phone: none,
  mentored: none,
  missed: none,
  covered: none,
  totaldue: none,
  date: none,
  body
) = {
  //Begin actual content
  grid(
    columns: (2fr, 0.5fr, 1fr),
    text(30pt)[*INVOICE*],
    [From:],
    [
      #text(16pt)[*#sender_name*] \
      #sender_address1 \
      #sender_address2 \
      #sender_phone \
      #sender_email
    ])
  
  linebreak()
  
  grid(
    columns: (0.5fr, 1.5fr, 0.5fr, 1fr),
    [Invoice For:],
    [
      #text(16pt)[*#recipient_name*] \
      #recipient_address1 \
      #recipient_address2 \
      #recipient_phone
    ],
    [
      Issue Date: \
      Terms:
    ],
    [
      #date \
      Due upon receipt
    ]
  )
  
  linebreak()
  
  $if(mentored)$
  table(
    fill: (x, y) =>
      if y == 0 {
        gray.lighten(70%)
      },
    columns: (1fr, auto, auto, auto),
    rows: 36pt,
    inset: 5pt,
    align: (left + horizon, center + horizon, right + horizon, right + horizon),
    stroke: 0.5pt, 
    [*Description*],
    [*Quantity*],
    [*Unit Price*],
    [*Total*],
    $for(mentored)$
      [_mentored_ $it.course$ for *$it.company$* \ from $it.start$ to $it.end$ (invoice $it.invoice$ of $it.invoices$)],table.cell(align: center)[1],table.cell(align: right)[$it.unitprice$],table.cell(align: right)[$it.unitprice$],
    $endfor$
    $for(missed)$
      [_missed_ $it.course$ for *$it.company$* \ on $it.date$],table.cell(align: center)[1],table.cell(align: right)[-121.00],table.cell(align: right)[-121.00],
    $endfor$
    $for(covered)$
      [_covered_ $it.course$ for *$it.company$* \ on $it.date$],table.cell(align: center)[1],table.cell(align: right)[133.00],table.cell(align: right)[133.00],
    $endfor$
    [ ],[ ],[ ],[ ],
    table.cell(colspan: 3, align: right, stroke: none)[*TOTAL AMOUNT DUE*],table.cell(stroke: 2pt)[*$totaldue$*],
  )
  $endif$
  body
}

