# Phrase bank for the open-ended answers (dataset version 1.1.0)
#
# Sourced by generate_wellbeing.R. Each answer is built from pieces so that
# answers rarely repeat: a core statement for the main theme (with {slots}
# filled at random), sometimes a detail sentence, sometimes a mention of a
# second theme, an optional opener and closer, and the variation found in real
# survey answers (very short answers, lower case, typos, missing full stops).
# The hand-coded theme is always the main theme.

slots <- list(
  weeks     = c("two weeks", "three weeks", "a month", "over a month", "six weeks"),
  chapter   = c("my literature review", "my methods chapter", "my proposal",
                "my first chapter", "my draft", "my questionnaire"),
  work      = c("teaching", "a part-time job", "my job at a school", "tutoring",
                "shifts at a hospital", "working in an office"),
  money     = c("rent", "tuition fees", "transport", "food and rent", "my loan"),
  person    = c("my mother", "my father", "my grandmother", "my husband", "my wife",
                "my younger brother"),
  kids      = c("my children", "my two kids", "my son", "my daughter", "a toddler",
                "three children"),
  place     = c("a new city", "another country", "the capital", "a city where I know no one"),
  symptom   = c("headaches", "back pain", "stomach problems", "insomnia", "panic attacks"),
  hours     = c("four or five hours", "five hours", "less than six hours", "barely four hours"),
  obstacle  = c("ethics approval", "finding participants", "access to the archives",
                "getting permission from schools", "the software licence")
)

fill <- function(template) {
  for (slot in names(slots)) {
    token <- paste0("{", slot, "}")
    while (grepl(token, template, fixed = TRUE)) {
      template <- sub(token, sample(slots[[slot]], 1), template, fixed = TRUE)
    }
  }
  template
}

varied_bank <- list(
  Supervision = list(
    core = c(
      "My supervisor is hard to reach and I often wait {weeks} for a reply.",
      "Getting feedback on {chapter} took {weeks}, and by then I had lost momentum.",
      "My supervisor and I see the project very differently.",
      "I never really know what my supervisor expects from me.",
      "Our meetings are rushed and I leave with more questions than answers.",
      "The direction of my thesis changed twice after comments from my supervisor.",
      "I feel uncomfortable asking my supervisor for help.",
      "My supervisor has too many students to give each of us proper time.",
      "Nobody tells me whether my work is good enough until it is too late.",
      "I sent {chapter} to my supervisor and heard nothing for {weeks}.",
      "The comments I get are very brief, so I have to guess what to fix.",
      "My supervisor went on leave for a semester and I was left on my own.",
      "I was assigned a supervisor from a different field who does not know my topic well.",
      "It is difficult to get my two supervisors to agree on anything."
    ),
    detail = c(
      "Sometimes I rewrite the same section again and again without knowing if it is right.",
      "Other students in my group seem to get much more attention.",
      "I have started to rely on friends for advice instead.",
      "It makes me doubt whether I am capable of finishing.",
      "When we do meet, the advice is useful, but it happens rarely.",
      "I am afraid to complain because I depend on their support."
    ),
    short = c("Supervisor.", "lack of supervision", "Feedback from my supervisor.",
              "My supervisor!", "getting guidance")
  ),
  Workload = list(
    core = c(
      "There is simply too much to do and never enough time.",
      "Combining coursework, {work} and my thesis leaves me no time to rest.",
      "Every deadline seems to fall in the same few weeks.",
      "I work late almost every night just to keep up.",
      "Writing {chapter} took far longer than I planned.",
      "The data collection for my project turned out to be enormous.",
      "I spend my weekends studying and still feel behind.",
      "Managing several assignments at the same time is exhausting.",
      "The reading list alone would take a year to get through.",
      "Keeping up with the pace of the programme is my biggest problem.",
      "I underestimated how much work a thesis is.",
      "Teaching duties take up most of the week, so my own research always comes last.",
      "I have to finish {chapter} and two assignments before the end of the month."
    ),
    detail = c(
      "I have a to-do list that never gets shorter.",
      "Some weeks I study more than sixty hours.",
      "I cannot remember the last time I took a full day off.",
      "It feels like running without ever reaching the finish line.",
      "Planning helps a little, but there is still too much.",
      "My sleep is the first thing to suffer when deadlines come."
    ),
    short = c("Time.", "workload", "Too much work.", "deadlines!!", "no time")
  ),
  Finances = list(
    core = c(
      "Paying {money} while supporting myself is a constant worry.",
      "My scholarship does not cover my living costs.",
      "I had to take {work} to pay for my studies.",
      "Most of my income goes on {money}.",
      "I worry about money more than about my research.",
      "Books, software and conference fees are expensive.",
      "My salary was paid late several times this year.",
      "I cannot afford to travel for data collection.",
      "I borrowed money from relatives to pay for this semester.",
      "My funding ends before my thesis will be finished.",
      "Prices have gone up but my stipend has not.",
      "I had to choose between buying a laptop and paying {money}."
    ),
    detail = c(
      "At the end of the month I sometimes skip meals.",
      "I feel embarrassed to talk about it with other students.",
      "The extra job means less time for my thesis.",
      "I check my bank account more often than my email.",
      "Without help from my family I would have had to stop."
    ),
    short = c("Money.", "financial problems", "Fees.", "money money money", "funding")
  ),
  Family = list(
    core = c(
      "Looking after {kids} while studying is very hard.",
      "My family needs me at home and I feel guilty working on my thesis.",
      "Caring for {person}, who was ill for most of the year, took much of my time.",
      "It is hard to find a quiet place to study at home.",
      "Balancing family responsibilities with research is my biggest challenge.",
      "My family does not understand why a postgraduate degree takes so long.",
      "After my baby was born I could not keep a study routine.",
      "Family events and obligations keep interrupting my plans.",
      "I can only work late at night, when everyone at home is asleep.",
      "When {person} was in hospital I missed a whole month of work.",
      "I am the only one at home who can drive, so my days are full of errands.",
      "Being a parent and a student at the same time means I am never fully either."
    ),
    detail = c(
      "I feel I am letting down both my family and my supervisor.",
      "Childcare is expensive and not always available.",
      "My partner helps, but it is still a struggle.",
      "Weekends belong to the family, not to my thesis.",
      "I often study at the kitchen table with noise all around me."
    ),
    short = c("Family.", "my kids", "family responsibilities", "Being a parent.", "home life")
  ),
  Health = list(
    core = c(
      "I have trouble sleeping, especially before deadlines.",
      "Stress has affected my health and I get {symptom} often.",
      "I feel tired all the time and cannot concentrate.",
      "I stopped exercising and I can feel the difference.",
      "Anxiety about my progress keeps me awake at night.",
      "I was ill for several weeks and fell behind.",
      "I drink far too much coffee just to stay awake.",
      "Burnout made me lose interest in my research for a while.",
      "Most nights I sleep {hours}.",
      "My mental health has been up and down all year.",
      "I started having {symptom} in my second semester.",
      "I feel exhausted even after the holidays."
    ),
    detail = c(
      "The doctor told me to slow down, but I do not see how.",
      "I finally went to the counselling service, which helped.",
      "Some mornings I cannot get out of bed.",
      "I know I should look after myself better.",
      "My concentration is so poor that simple tasks take hours."
    ),
    short = c("Stress.", "sleep", "mental health", "Burnout.", "being tired all the time")
  ),
  Isolation = list(
    core = c(
      "I moved to {place} for my studies and I feel lonely.",
      "Research is a lonely process and I miss working with others.",
      "I hardly know anyone in my department.",
      "Being far from my family makes the bad days worse.",
      "There are few chances to meet other postgraduate students.",
      "I work alone most of the time with no one to share ideas with.",
      "I feel like an outsider in my research group.",
      "I miss home, especially during exams.",
      "Most of my friends have finished studying and moved on.",
      "Since moving to {place} I have spent most evenings alone.",
      "Nobody in my group works on anything close to my topic.",
      "The other students already knew each other when I arrived."
    ),
    detail = c(
      "Weeks can pass without a real conversation about my work.",
      "I call my family every day, but it is not the same.",
      "A study group would make a big difference.",
      "I did not expect it to feel so isolating.",
      "Online meetings do not replace having people around."
    ),
    short = c("Loneliness.", "being alone", "Isolation.", "no friends here", "homesickness")
  ),
  Other = list(
    core = c(
      "Getting {obstacle} took much longer than planned.",
      "Finding participants for my study was a real problem.",
      "Learning statistics for my analysis was harder than I expected.",
      "The library does not have many of the journals I need.",
      "University procedures are slow and confusing.",
      "Writing in academic English is my biggest challenge.",
      "Power cuts made it hard to work in the evenings.",
      "Finding reliable sources in my own language was difficult.",
      "My laptop broke in the middle of the semester and I lost some files.",
      "The internet at home is too slow for online classes.",
      "Everything depended on {obstacle}, which was delayed for months.",
      "Learning to use the analysis software took most of my first year."
    ),
    detail = c(
      "It delayed my whole timeline.",
      "Nobody could tell me who was responsible.",
      "I had to teach myself from online videos.",
      "It was frustrating because it was outside my control.",
      "Now it is solved, but I lost a lot of time."
    ),
    short = c("Bureaucracy.", "statistics", "English writing", "the internet", "ethics approval")
  )
)

# Short phrases used when a second theme is mentioned
second_mentions <- list(
  Supervision = c("my supervisor is hard to reach", "the feedback on my work is slow",
                  "I get little guidance", "my supervisor and I do not always agree"),
  Workload    = c("the workload is heavy", "there are too many deadlines",
                  "I never have enough time", "the reading never ends"),
  Finances    = c("money is tight", "my scholarship is not enough",
                  "I also have to work to pay {money}", "the fees keep going up"),
  Family      = c("my family needs me", "I look after {kids}",
                  "home is not a quiet place to study", "{person} has been ill"),
  Health      = c("I sleep badly", "I am always tired", "stress gives me {symptom}",
                  "my mental health has suffered"),
  Isolation   = c("I feel lonely here", "I miss my family",
                  "I do not have friends in the department", "I work alone all the time"),
  Other       = c("the university paperwork is slow", "statistics is hard for me",
                  "{obstacle} was delayed", "my English writing needs work")
)

openers <- c("Honestly, ", "To be honest, ", "For me, ", "Mainly ", "I would say ",
             "Probably ", "Definitely ", "The biggest one is that ")
joiners <- c(" Also, ", " On top of that, ", " And ", " Besides that, ",
             " At the same time, ", " Plus ")
typo_map <- c("difficult" = "dificult", "because" = "becuase", "research" = "reserch",
              "family" = "familly", "different" = "diffrent", "feedback" = "feed back",
              "supervisor" = "supervsor", "exhausting" = "exausting",
              "department" = "departement", "finish" = "finsh", "lonely" = "lonley")

decap_first <- function(x) {
  if (grepl("^I[ ']", x)) x else paste0(tolower(substr(x, 1, 1)), substring(x, 2))
}

# main: the hand-coded theme; second: another theme or ""; dropout and workshop
# flags allow closing remarks that fit the student's data
write_varied <- function(main, second, dropout, workshop) {
  bank <- varied_bank[[main]]
  if (runif(1) < 0.07) return(sample(bank$short, 1))
  text <- fill(sample(bank$core, 1))
  if (runif(1) < 0.20) {
    text <- paste0(sample(openers, 1), decap_first(text))
  }
  if (runif(1) < 0.35) text <- paste(text, fill(sample(bank$detail, 1)))
  if (second != "") {
    mention <- fill(sample(second_mentions[[second]], 1))
    text <- paste0(text, sample(joiners, 1), mention, ".")
  }
  closers <- c("It has been a hard year.", "I hope next year is better.",
               "Otherwise the programme is fine.", "I am coping, but only just.",
               "Things are slowly improving.")
  if (dropout) closers <- c(closers, "Some days I think about quitting.",
                            "I have seriously thought about leaving the programme.")
  if (workshop) closers <- c(closers, "The wellbeing workshop helped a little.")
  if (runif(1) < 0.30) text <- paste(text, sample(closers, 1))
  # Variation found in real answers
  if (runif(1) < 0.10) {
    hit <- names(typo_map)[vapply(names(typo_map), grepl, logical(1), x = text)]
    if (length(hit) > 0) text <- sub(hit[1], typo_map[[hit[1]]], text)
  }
  if (runif(1) < 0.10) text <- decap_first(text)
  if (runif(1) < 0.12) text <- sub("\\.$", "", text)
  text
}
