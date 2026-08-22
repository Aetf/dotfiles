// Gmail labels & filters, managed declaratively by gmailctl (Aetf/meta#10).
//
// Workflow: edit -> `gmailctl --config ~/.config/gmailctl diff` -> `apply`
// -> yadm commit. Don't create filters in the Gmail web UI: the next apply
// clobbers them (run `download` first to rescue anything created there).
//
// Labels listed here are authoritative too — removing one DELETES it in
// Gmail (messages keep other labels but lose that one). ❄️Z-OldLabels/* are
// frozen archival labels with no live traffic; keep them.

local label(name, bg=null, text=null) =
  { name: name } +
  (if bg == null then {} else { color: { background: bg, text: text } });

// ---------------------------------------------------------------------------
// Labels
// ---------------------------------------------------------------------------

local activeLabels = [
  label('AWS Bills'),
  label('Auto Insurance'),
  label('Auto Insurance/20250312-scratch-with-neighbor'),
  label('Bank Statements'),
  label('CarMaintenance'),
  label('DMARC-Issue'),
  label('GoodToGo'),
  label('Housing'),
  label('Housing/Utility'),
  label('Housing/Woodcreek'),
  label('Housing/Woodcreek/HVAC upgrade'),
  label('Insurance'),
  label('Purchase'),
  label('Registration', '#00ff00', '#000000'),
  label('省钱'),
];

local personalLabels = [
  label('个人事物'),
  label('个人事物/20240810 Wedding', '#ffc8af', '#7a2e0b'),
  label('个人事物/20241115 H1B签证'),
  label('个人事物/GreenCard'),
  label('个人事物/Offer'),
  label('个人事物/PS'),
  label('个人事物/买房 Homebuying', '#fbe983', '#594c05'),
  label('个人事物/买房 Homebuying/Bay Equity', '#ffad46', '#ffffff'),
  label('个人事物/买房 Homebuying/Fairway', '#42d692', '#094228'),
  label('个人事物/买房 Homebuying/Redfin'),
  label('个人事物/出国中介'),
  label('个人事物/手机账单'),
  label('个人事物/推荐信'),
  label('个人事物/日本毕业旅行'),
];

local travelTrips = [
  '2019-03-02 MLSys20',
  '2019-7-4 Orlando',
  '2019-08-24 塞尔维亚',
  '2019-12-26 圣诞美国中南',
  '2021-04-06 MLSys21',
  '2021-07-04 缅因',
  '2021-12-29 新奥尔良',
  '2022-09-02 夏威夷Maui',
  '2022-11-23 Portland 脱口秀',
  '2022-12-20 Lake Tahoe 滑雪',
  '2023-04-28 毕业典礼',
  '2023-05-28 波特兰',
  '2023-06-25 温哥华',
  '2024-04-02 SVL出差',
  '2024-07-04 加州婚纱照',
  '2024-08 婚礼父母来美',
  '2024-09-06 Niagara Falls',
  '2024-11 加拿大和日本',
  '2024-11-13 加州',
  '2024-12-05 日本',
  '2025-02-18 加州出差',
  '2025-04-10 回国',
  '2025-07-04 Olympic Nation Park',
  '2025-07-09 加州出差',
  '2025-07-30 Glacier National Park',
  '2025-09-22 SVL',
  '2026-04-18 加拿大周末',
  '2026-05-02 SymbioticLab 10周年',
  '2026-10-30 夏威夷芳芳婚礼',
  '2027-01-04 夏威夷',
];
local travelLabels = [label('旅行')] + [label('旅行/' + t) for t in travelTrips];

// Aetf/meta#10 mail automation: gmailctl applies bot/pending/<rule>;
// the processor picks work up by label, swaps to bot/done (or bot/error)
// when finished. State lives in Gmail itself, so the pipeline is idempotent.
local botLabels = [
  label('bot'),
  label('bot/pending'),
  label('bot/pending/utility-bill'),
  label('bot/done'),
  label('bot/error'),
];

local frozenLabels = [
  label('❄️Z-OldLabels'),
  label("❄️Z-OldLabels/Aetf's Bot Message"),
  label('❄️Z-OldLabels/Archlinux'),
  label('❄️Z-OldLabels/AttachmentRemoved'),
  label('❄️Z-OldLabels/Craigslist'),
  label('❄️Z-OldLabels/Facebook/Intern2019', '#4986e7', '#ffffff'),
  label('❄️Z-OldLabels/Google Scholar'),
  label('❄️Z-OldLabels/Google/Fulltime2022', '#98d7e4', '#0d3b44'),
  label('❄️Z-OldLabels/Google/Fulltime2022/Reloc'),
  label('❄️Z-OldLabels/Google/Fulltime2022/ToSeattle'),
  label('❄️Z-OldLabels/Google/Fulltime2022/Visa'),
  label('❄️Z-OldLabels/Job Application'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Apple'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Bytedance'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Dropbox'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Facebook'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Microsoft'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Nvidia'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Snap'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Uber'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Done/Waymo'),
  label('❄️Z-OldLabels/Job Application/Fulltime2022/Google'),
  label('❄️Z-OldLabels/Job Application/Intern2021'),
  label('❄️Z-OldLabels/Job Application/Intern2021/Amazon'),
  label('❄️Z-OldLabels/kdevelop-devel'),
  label('❄️Z-OldLabels/Mail & Package'),
  label('❄️Z-OldLabels/Mozilla'),
  label('❄️Z-OldLabels/Symbiotic', '#ff7537', '#ffffff'),
  label('❄️Z-OldLabels/UMich'),
  label('❄️Z-OldLabels/UMich/Dissertation', '#ffc8af', '#7a2e0b'),
  label('❄️Z-OldLabels/UMich/EECS 489 Auto Grader'),
  label('❄️Z-OldLabels/UMich/EECS 551 Auto Grader'),
  label('❄️Z-OldLabels/UMich/EECS 598-009 Big Data'),
  label('❄️Z-OldLabels/UMich/Health'),
  label('❄️Z-OldLabels/UMich/rloopfma'),
  label('❄️Z-OldLabels/XJTU'),
  label('❄️Z-OldLabels/XJTU/Reg'),
  label('❄️Z-OldLabels/XJTU/推荐信'),
  label('❄️Z-OldLabels/事务'),
  label('❄️Z-OldLabels/事务/Google奖学金'),
  label('❄️Z-OldLabels/事务/LianLiFan RMA'),
  label('❄️Z-OldLabels/事务/UCLA CSST'),
  label('❄️Z-OldLabels/事务/sAohE'),
  label('❄️Z-OldLabels/事务/网安'),
];

// ---------------------------------------------------------------------------
// Rules
// ---------------------------------------------------------------------------

// One or-branch per bank's "statement is ready" notification wording.
local statementQueries = [
  '"Your credit card statement is ready"',
  '"Your statement is ready for credit card"',
  '"Your statement for credit card"',
  '"Your statement is ready for account"',
  '("credit card statement" ("ready" or "available"))',
  '"Your statement is available online"',
  '"You have a new statement online"',
  '("Your statement is now available online" citi)',
  '"Your Statement is Available in Mobile and Online Banking"',
  '"Your deposit statement is available"',
  '"billing statement available"',
  '(american express "Important Notice" Statement)',
  '(from:donotreply-comm@schwab.com "Your Schwab eStatement is Ready")',
  '(schwab bank estatement)',
  '(from:no-reply@icbc-us.com subject:"Statement Alert")',
  '("citizens" access "monthly statement")',
  '"sofi banking statement is available"',
  '(monthly (green dot|wealthfront) statement)',
];

local financeRules = [
  {
    filter: { or: [{ query: q } for q in statementQueries] },
    actions: {
      archive: true,
      markSpam: false,
      markImportant: false,
      category: 'updates',
      labels: ['Bank Statements'],
    },
  },
  // Payment confirmations and autopay reminders: noise once autopay works.
  {
    filter: {
      or: [
        {
          and: [
            { from: 'billpay@billpay.bankofamerica.com' },
            { subject: 'new eBill', isEscaped: true },
          ],
        },
        { query: '"autopay payment reminder"' },
        { query: '"We processed your payment"' },
      ],
    },
    actions: {
      archive: true,
      markRead: true,
      markImportant: false,
      category: 'updates',
    },
  },
  // Payment still in flight — deliberately left in the inbox.
  {
    filter: {
      subject: '"payment is scheduled for delivery" | "received your payment"',
      isEscaped: true,
    },
    actions: { markSpam: false, markImportant: false, category: 'personal' },
  },
  {
    filter: { query: '"Amazon web services invoice available"' },
    actions: { archive: true, labels: ['AWS Bills'] },
  },
  {
    filter: { query: '"Good To Go! statement"' },
    actions: { archive: true, labels: ['GoodToGo'] },
  },
  // Brokerage marketing/notice noise.
  {
    filter: { from: 'moomoo' },
    actions: { archive: true, markRead: true },
  },
];

local insuranceRules = [
  {
    filter: {
      or: [
        { from: 'meemic' },
        { from: 'customerservice@e.progressive.com' },
        { query: '"Metromile monthly statement available"' },
      ],
    },
    actions: { markSpam: false, category: 'updates', labels: ['Auto Insurance'] },
  },
];

local purchaseRules = [
  // Order confirmations (excluding paypal/amex payment receipts).
  {
    filter: {
      and: [
        { from: '-paypal -americanexpress', isEscaped: true },
        { query: 'thank order -{recent rate survey}' },
      ],
    },
    actions: { category: 'updates', labels: ['Purchase'] },
  },
  // Carrier tracking updates.
  {
    filter: {
      query: 'from:TrackingUpdates@fedex.com OR from:order-update@amazon.com OR from:auto-reply@usps.com OR from:USPSInformeddelivery@email.informeddelivery.usps.com OR from:mcinfo@ups.com OR (from:help@walmart.com  AND (subject:"Out for delivery" OR subject:"shipped" OR subject:"delivered") )',
    },
    actions: {
      archive: true,
      markSpam: false,
      category: 'updates',
      labels: ['❄️Z-OldLabels/Mail & Package'],
    },
  },
];

local dealsRules = [
  {
    filter: {
      or: [
        { from: 'dealalerts@slickdeals.net' },
        { and: [{ from: 'admin@dealmoon.com' }, { subject: '即时折扣' }] },
      ],
    },
    actions: { markRead: true, labels: ['省钱'] },
  },
];

local housingRules = [
  {
    filter: { from: 'woodcreek_mgr@outlook.com' },
    actions: { labels: ['Housing/Woodcreek'] },
  },
  // PSE bill — deliberately left in the inbox.
  {
    filter: {
      or: [
        { and: [{ from: 'pugetsoundenergy@pse.com' }, { query: 'energy bill' }] },
        { query: '(puget sound energy "energy bill is ready")' },
      ],
    },
    actions: {
      markSpam: false,
      markImportant: false,
      category: 'updates',
      labels: ['Housing/Utility', 'bot/pending/utility-bill'],
    },
  },
  // Other utility notices: archive, they're on autopay.
  {
    filter: {
      or: [
        { query: '(subject:"city of bellevue" subject:"invoice")' },
        { from: 'noreply@republicservices.com' },
        {
          and: [
            { from: 'online.communications@alerts.comcast.net' },
            { query: '"your bill is ready to view"' },
          ],
        },
      ],
    },
    actions: {
      archive: true,
      markRead: true,
      markSpam: false,
      category: 'updates',
      labels: ['Housing/Utility', 'bot/pending/utility-bill'],
    },
  },
];

local aliasRules = [
  // Throwaway alias: straight to promotions, out of sight.
  {
    filter: { query: 'to:junk@unlimitedcodeworks.xyz OR to:junk@unlimited-code.works' },
    actions: {
      archive: true,
      markRead: true,
      markImportant: false,
      category: 'promotions',
    },
  },
  // Aliases used by family — hand off.
  {
    filter: {
      to: '(unlimitedcodeworks.xyz (newegg OR sameto212 OR xavih886))',
      isEscaped: true,
    },
    actions: {
      archive: true,
      markRead: true,
      markSpam: false,
      markImportant: false,
      forward: 'fwd@jieyou.info',
    },
  },
];

local botRules = [
  // Self-hosted infra mail (SMART reports etc.) — never spam, always important.
  {
    filter: {
      or: [
        { query: 'from:"Aetf\'s Bot Message"' },
        { and: [{ from: 'master@unlimited-code.works' }, { query: 'SMART' }] },
      ],
    },
    actions: {
      markSpam: false,
      markImportant: true,
      category: 'personal',
      labels: ["❄️Z-OldLabels/Aetf's Bot Message"],
    },
  },
];

local devRules = [
  {
    filter: { query: '"renovate[bot]"' },
    actions: {
      archive: true,
      markRead: true,
      markImportant: false,
      category: 'updates',
    },
  },
];

// Michigan / school era. Dead or near-dead traffic; kept until deliberately
// retired. Deletion candidates the next time this file is touched.
local legacyRules = [
  {
    filter: { query: 'Archlinux' },
    actions: { category: 'updates', labels: ['❄️Z-OldLabels/Archlinux'] },
  },
  {
    filter: { from: 'scholaralerts-noreply@google.com' },
    actions: { labels: ['❄️Z-OldLabels/Google Scholar'] },
  },
  {
    filter: { from: 'bugzilla-daemon@mozilla.org' },
    actions: { labels: ['❄️Z-OldLabels/Mozilla'] },
  },
  {
    filter: { from: 'facebook-recruiting@fb.com' },
    actions: { labels: ['❄️Z-OldLabels/Job Application'] },
  },
  {
    filter: { from: 'update+zj4y=_j4yf9c@facebookmail.com' },
    actions: { archive: true, markRead: true, category: 'social' },
  },
  {
    filter: { query: 'CLOUDLAB.US: Profile updated from Git repository' },
    actions: { archive: true, markRead: true },
  },
  {
    filter: {
      or: [
        { query: '(mosharaf group meeting)' },
        { query: 'subject:"[Reminder] Group meeting today"' },
        { to: 'symbiotic@umich.edu' },
        { from: 'symbiotic@umich.edu' },
      ],
    },
    actions: { labels: ['❄️Z-OldLabels/Symbiotic'] },
  },
  {
    filter: {
      or: [
        { query: 'list:kdevelop-devel.kde.org' },
        { query: 'list:kdevelop.kde.org' },
        { query: '(REVISION SUMMARY)' },
        { from: 'noreply@phabricator.kde.org' },
      ],
    },
    actions: { archive: true, markSpam: false, labels: ['❄️Z-OldLabels/kdevelop-devel'] },
  },
  {
    filter: { query: 'Michigan-BigData' },
    actions: {
      archive: true,
      markRead: true,
      markSpam: false,
      labels: ['❄️Z-OldLabels/UMich/EECS 598-009 Big Data'],
    },
  },
  // DTE Energy (Michigan utility).
  {
    filter: {
      or: [
        {
          and: [
            { from: 'DTEEnergybill@dteenergy.com' },
            { query: 'DTE Energy bill is ready to view' },
          ],
        },
        {
          and: [
            { from: 'NOREPLY@notifications.dteenergy.com' },
            { query: 'dte energy payment received' },
          ],
        },
      ],
    },
    actions: {
      archive: true,
      markSpam: false,
      category: 'updates',
      labels: ['Housing/Utility'],
    },
  },
];

{
  version: 'v1alpha3',
  author: {
    name: 'Aetf',
    email: 'aetf@unlimited-code.works',
  },
  labels: activeLabels + personalLabels + travelLabels + botLabels + frozenLabels,
  rules:
    financeRules
    + insuranceRules
    + purchaseRules
    + dealsRules
    + housingRules
    + aliasRules
    + botRules
    + devRules
    + legacyRules,
}
