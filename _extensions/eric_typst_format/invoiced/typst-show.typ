#show: doc => {

invoiced(
  $if(sender.name)$
    sender_name: [$sender.name$],
  $endif$
  $if(sender.address1)$
    sender_address1: [$sender.address1$],
  $endif$
  $if(sender.address2)$
    sender_address2: [$sender.address2$],
  $endif$
  $if(sender.phone)$
    sender_phone: [$sender.phone$],
  $else$
    sender_phone: none,
  $endif$
  $if(sender.email)$
    sender_email: [$sender.email$],
  $else$
    sender_email: none,
  $endif$
  $if(recipient.name)$
    recipient_name: [$recipient.name$],
  $else$
    recipient_name: [Posit PBC],
  $endif$
  $if(recipient.address1)$
    recipient_address1: [$recipient.address1$],
  $else$
    recipient_address1: [250 Northern Ave],
  $endif$
  $if(recipient.address2)$
    recipient_address2: [$recipient.address2$],
  $else$
    recipient_address2: [Boston, MA 02210],
  $endif$
  $if(recipient.phone)$
    recipient_phone: [$recipient.phone$],
  $else$
    recipient_phone: none,
  $endif$
  $if(mentored)$
    mentored: [$mentored$],
  $endif$
  $if(missed)$
    missed: [$missed$],
  $endif$
  $if(covered)$
    covered: [$covered$],
  $endif$
  $if(totaldue)$
    totaldue: [$totaldue$],
  $endif$
  $if(date)$
    date: [$date$],
  $else$
    date: [#datetime.today().display()],
  $endif$
  doc
)
}