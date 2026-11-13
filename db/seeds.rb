# Demo data for local development. Run with: bin/rails db:seed
# Safe to run more than once (find_or_create_by! won't duplicate records).
# These are throwaway local-only accounts.

password = "password123"

editor = User.find_or_create_by!(email: "editor@example.com") do |u|
  u.password = password
  u.role = :editor
end

User.find_or_create_by!(email: "reader@example.com") do |u|
  u.password = password
end

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = password
  u.role = :admin
end

# Articles grouped by category. Within each category, the article listed last
# is created last, so it counts as the newest and shows first on the site.
articles = {
  "Lifestyle" => [
    {
      title: "Key Tips for a Healthier Lifestyle",
      content: "Maintaining a healthy lifestyle is essential for overall well-being. Here are the main tips to help you lead a healthier life: regular exercise, balanced nutrition, and don't be a fucking asshole."
    },
    {
      title: "How to make love to your friend's smoking hot wife",
      content: "Making love to your friend's smoking hot wife can be a delicate situation. Here are some tips to navigate this potentially complicated terrain: there's absolutely no way you actually decided to read this article LMAOOO. Keep dreaming big bro!"
    },
    {
      title: "Local Man Discovers ONE Secret Trip To Attract Women--Dating Apps Are FURIOUS!!",
      content: "A 26-year-old unemployed man has reportedly unlocked a FORBIDDEN dating technique so powerful that Tinder executives have called an emergency meeting. His secret? Showering and maintaining eye contact.
    'I used to get zero play,' explained Tyler McGyatterson, a Diamond-ranked Discord moderator. 'Then I stopped referring to women as 'females' and suddenly my aura increased by 9000%.' Experts are calling it the Great Gooner Awakening of 2026.
    Within 48 hours, Tyler reportedly received THREE compliments, TWO phone numbers, and ONE restraining order after attempting to demonstrate his 'unspoken rizz' inside a Target. The discovery has sent shockwaves through the incel community.
    'Bro literally betrayed the council,' commented Reddit user xXSkibidiSigma420Xx. 'Next you're gonna tell me brushing my teeth is meta.'  Scientists warn that excessive hygiene could cause irreversible side effects, including employment, healthy relationships, and conversations with actual human beings."
    }
  ],

  "Technology" => [
    {
      title: "Lottery Glitch Leaves Local Man Homeless",
      content: "In an unexpected turn of events, previous lottery winner--dubbed as Man-Man--found himself in a rather unfortunate situation where the supposed earnings brought about by his recent lottery win was the result of a software glitch which in turn forced him to submit all his earnings to collections.
    As unfortunate as it is, Man-Man cut off his family, friends, and job which not only leaves him penniless from his winnings, but also unemployed and homeless. US Gamblers and Lottery LLC, the company responsible for the lottery tickets, refused to comment regarding their appeasement rejection for the glitch.
    Should there be any attempts to make amends for life-altering mistake that affects individuals such as Man-Man or must players such as himself be forced to contest and challenge the will and rule of these companies? Regardless of the outcome, we all know The 'house always wins'"
    },
    {
      title: "Nord finally releases cheaper keyboard",
      content: "Nord, the company known for its high-quality keyboards, has recently released a new model that is more affordable than their previous offerings. The new keyboard, called the Nord Stage Lite, is designed for musicians and producers who want a high-quality instrument without breaking the bank.
    The Nord Stage Lite features a compact design, high-quality keybed, and a range of sounds and effects that make it a versatile tool for music production. With its lower price point, the Nord Stage Lite is expected to appeal to a wider audience of musicians and producers. The Nord Stage lite is currently priced at a whopping $4999, making it the cheapest Nord Stage to date!"
    },
    {
      title: "Will AI Replace Your Girlfriend? Experts Weigh In",
      content: "As AI technology continues to advance, many people are wondering if it will eventually replace human relationships, including romantic ones. Well, the first answer is hell no. The second answer is you need to go outside, touch grass, and go talk to some fucking human women. Claude and ChatGPT are not your girlfriends, and they never will be. If you want a girlfriend, go out and meet some real women. Stop being a fucking loser bruh!!!"
    }
  ],

  "World" => [
    {
      title: "Local Man Wins Lottery",
      content: "Local man (per confidentiality safety clause we will call him Man-Man) wins lottery after years of unsuccessful attempts.
    Man-Man is credited for having now 'won in life'. Regardless of the exorbitant taxes that were taken as per gambling guidelines,
    he is pretty much set for the remainder of his life. It is said that Man-Man immediately quit his job and cut his family and friends off immediately after his sudden win.
    Who knows what life has in store for Man-Man's next chapter?"
    },
    {
      title: "Local Man Gets The Job of His Dreams",
      content: "Local man gets the job of his dreams after years of searching. He is now working as a software engineer at a top tech company and is thrilled to be doing what he loves while still pursuing his musical passions.
    The man credits his success to his perseverance and dedication to his craft and support of his family, friends, and loving girlfriend. He hopes to inspire others to pursue their passions and never give up on their dreams!"
    }
  ]
}

articles.each do |category, list|
  list.each do |data|
    Article.find_or_create_by!(title: data[:title]) do |article|
      article.category = category
      article.content  = data[:content]
      article.user     = editor
    end
  end
end

puts "Seeded #{User.count} users and #{Article.count} articles."
