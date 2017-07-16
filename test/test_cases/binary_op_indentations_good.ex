"No matching message.\n" <>
"Process mailbox:\n" <>
mailbox

"The Bronze Age trumpet's" <> "tone of exile" <> "hovers over bottomlessness."

"In the first hours of day" <>
"consciousness can embrace the world" <>
"just as the hand grasps a sun-warm stone."
"The traveler stands under the tree. After" <>
"the plunge through" <> # death's whirling vortex, will
"a great light" # unfurl over his head?

defp update_context(curr_ctx) do
  curr_lineno = curr_ctx[:line]
  [{:suffix_comments, get_suffix_comments(curr_lineno + 1)}] ++ curr_ctx
end
defp update_context(curr_ctx, prev_ctx) do
  curr_lineno = curr_ctx[:line]
  prev_lineno = prev_ctx[:line]

  [{:prev, prev_lineno}] ++
  [{:prefix_comments, get_prefix_comments(curr_lineno - 1, prev_lineno)}] ++
  [{:prefix_newline, get_prefix_newline(curr_lineno - 1, prev_lineno)}] ++
  curr_ctx
end
