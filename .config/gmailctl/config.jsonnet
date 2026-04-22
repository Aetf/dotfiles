// Please refer to https://github.com/mbrt/gmailctl#configuration for docs about
// the config format. Don't forget to change the configuration before to apply it
// to your own inbox!

// Import the standard library
local lib = import 'gmailctl.libsonnet';

// Some useful variables on top
// TODO: Put your email here
local me = 'YOUR.EMAIL@gmail.com';
local toMe = { to: me };

{
  version: "v1alpha3",
  author: {
    name: "Aetf",
    email: "aetf@unlimited-code.works"
  },
  // Note: labels management is optional. If you prefer to use the
  // GMail interface to add and remove labels, you can safely remove
  // this section of the config.
  labels: [
    {
      name: "旅行/2024-08 婚礼父母来美"
    },
    {
      name: "旅行/2021-07-04 缅因"
    },
    {
      name: "个人事物/20241115 H1B签证"
    },
    {
      name: "❄️Z-OldLabels/Google Scholar"
    },
    {
      name: "旅行/2023-05-28 波特兰"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Waymo"
    },
    {
      name: "Housing/Woodcreek"
    },
    {
      name: "❄️Z-OldLabels/事务/Google奖学金"
    },
    {
      name: "Bank Statements"
    },
    {
      name: "❄️Z-OldLabels/事务"
    },
    {
      name: "个人事物/手机账单"
    },
    {
      name: "❄️Z-OldLabels/Mozilla"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Apple"
    },
    {
      name: "个人事物"
    },
    {
      name: "❄️Z-OldLabels/Aetf's Bot Message"
    },
    {
      name: "个人事物/出国中介"
    },
    {
      name: "个人事物/推荐信"
    },
    {
      name: "旅行/2019-12-26 圣诞美国中南"
    },
    {
      name: "个人事物/PS"
    },
    {
      name: "❄️Z-OldLabels/Mail \u0026 Package"
    },
    {
      name: "❄️Z-OldLabels/XJTU"
    },
    {
      name: "❄️Z-OldLabels/Google/Fulltime2022/ToSeattle"
    },
    {
      name: "❄️Z-OldLabels/XJTU/Reg"
    },
    {
      name: "❄️Z-OldLabels/XJTU/推荐信"
    },
    {
      name: "❄️Z-OldLabels/Symbiotic",
      color: {
        background: "#ff7537",
        text: "#ffffff"
      }
    },
    {
      name: "Registration",
      color: {
        background: "#00ff00",
        text: "#000000"
      }
    },
    {
      name: "❄️Z-OldLabels/Archlinux"
    },
    {
      name: "❄️Z-OldLabels/Google/Fulltime2022/Visa"
    },
    {
      name: "个人事物/Offer"
    },
    {
      name: "❄️Z-OldLabels/事务/sAohE"
    },
    {
      name: "❄️Z-OldLabels/UMich/EECS 489 Auto Grader"
    },
    {
      name: "旅行/2019-03-02 MLSys20"
    },
    {
      name: "❄️Z-OldLabels/Facebook/Intern2019",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done"
    },
    {
      name: "个人事物/日本毕业旅行"
    },
    {
      name: "旅行/2024-11-13 加州"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Bytedance"
    },
    {
      name: "❄️Z-OldLabels/UMich"
    },
    {
      name: "个人事物/买房 Homebuying/Fairway",
      color: {
        background: "#42d692",
        text: "#094228"
      }
    },
    {
      name: "Housing"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Uber"
    },
    {
      name: "❄️Z-OldLabels/UMich/Health"
    },
    {
      name: "Housing/Woodcreek/HVAC upgrade"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022"
    },
    {
      name: "旅行/2023-04-28 毕业典礼"
    },
    {
      name: "旅行/2019-7-4 Orlando"
    },
    {
      name: "❄️Z-OldLabels/事务/LianLiFan RMA"
    },
    {
      name: "Housing/Utility"
    },
    {
      name: "旅行/2019-08-24 塞尔维亚"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Nvidia"
    },
    {
      name: "❄️Z-OldLabels/事务/UCLA CSST"
    },
    {
      name: "旅行/2024-04-02 SVL出差"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Intern2021/Amazon"
    },
    {
      name: "旅行/2022-09-02 夏威夷Maui"
    },
    {
      name: "省钱"
    },
    {
      name: "个人事物/买房 Homebuying/Bay Equity",
      color: {
        background: "#ffad46",
        text: "#ffffff"
      }
    },
    {
      name: "❄️Z-OldLabels/UMich/rloopfma"
    },
    {
      name: "❄️Z-OldLabels/Google/Fulltime2022/Reloc"
    },
    {
      name: "❄️Z-OldLabels/事务/网安"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Facebook"
    },
    {
      name: "CarMaintenance"
    },
    {
      name: "个人事物/买房 Homebuying/Redfin"
    },
    {
      name: "❄️Z-OldLabels/Job Application"
    },
    {
      name: "旅行/2024-12-05 日本"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Google"
    },
    {
      name: "旅行/2021-04-06 MLSys21"
    },
    {
      name: "旅行/2024-11 加拿大和日本"
    },
    {
      name: "❄️Z-OldLabels/UMich/EECS 598-009 Big Data"
    },
    {
      name: "旅行/2022-11-23 Portland 脱口秀"
    },
    {
      name: "❄️Z-OldLabels/Craigslist"
    },
    {
      name: "旅行/2023-06-25 温哥华"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Intern2021"
    },
    {
      name: "Auto Insurance"
    },
    {
      name: "旅行/2021-12-29 新奥尔良"
    },
    {
      name: "旅行/2024-07-04 加州婚纱照"
    },
    {
      name: "❄️Z-OldLabels/AttachmentRemoved"
    },
    {
      name: "Purchase"
    },
    {
      name: "旅行/2022-12-20 Lake Tahoe 滑雪"
    },
    {
      name: "旅行/2024-09-06 Niagara Falls"
    },
    {
      name: "个人事物/20240810 Wedding",
      color: {
        background: "#ffc8af",
        text: "#7a2e0b"
      }
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Snap"
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Dropbox"
    },
    {
      name: "❄️Z-OldLabels/kdevelop-devel"
    },
    {
      name: "❄️Z-OldLabels/Google/Fulltime2022",
      color: {
        background: "#98d7e4",
        text: "#0d3b44"
      }
    },
    {
      name: "❄️Z-OldLabels/Job Application/Fulltime2022/Done/Microsoft"
    },
    {
      name: "❄️Z-OldLabels/UMich/Dissertation",
      color: {
        background: "#ffc8af",
        text: "#7a2e0b"
      }
    },
    {
      name: "❄️Z-OldLabels"
    },
    {
      name: "旅行"
    },
    {
      name: "❄️Z-OldLabels/UMich/EECS 551 Auto Grader"
    },
    {
      name: "个人事物/买房 Homebuying",
      color: {
        background: "#fbe983",
        text: "#594c05"
      }
    },
    {
      name: "Insurance"
    }
  ],
  rules: [
    {
      filter: {
        query: "Archlinux"
      },
      actions: {
        category: "updates",
        labels: [
          "❄️Z-OldLabels/Archlinux"
        ]
      }
    },
    {
      filter: {
        from: "update+zj4y=_j4yf9c@facebookmail.com"
      },
      actions: {
        archive: true,
        markRead: true,
        category: "social"
      }
    },
    {
      filter: {
        from: "scholaralerts-noreply@google.com"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Google Scholar"
        ]
      }
    },
    {
      filter: {
        from: "bugzilla-daemon@mozilla.org"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Mozilla"
        ]
      }
    },
    {
      filter: {
        query: "mosharaf group meeting"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Symbiotic"
        ]
      }
    },
    {
      filter: {
        subject: "[Reminder] Group meeting today",
        isEscaped: true
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Symbiotic"
        ]
      }
    },
    {
      filter: {
        to: "symbiotic@umich.edu"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Symbiotic"
        ]
      }
    },
    {
      filter: {
        from: "symbiotic@umich.edu,"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Symbiotic"
        ]
      }
    },
    {
      filter: {
        from: "dealalerts@slickdeals.net"
      },
      actions: {
        markRead: true,
        labels: [
          "省钱"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "admin@dealmoon.com"
          },
          {
            subject: "即时折扣"
          }
        ]
      },
      actions: {
        markRead: true,
        labels: [
          "省钱"
        ]
      }
    },
    {
      filter: {
        from: "facebook-recruiting@fb.com"
      },
      actions: {
        labels: [
          "❄️Z-OldLabels/Job Application"
        ]
      }
    },
    {
      filter: {
        from: "meemic"
      },
      actions: {
        labels: [
          "Auto Insurance"
        ]
      }
    },
    {
      filter: {
        from: "customerservice@e.progressive.com"
      },
      actions: {
        labels: [
          "Auto Insurance"
        ]
      }
    },
    {
      filter: {
        query: "list:kdevelop-devel.kde.org"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "❄️Z-OldLabels/kdevelop-devel"
        ]
      }
    },
    {
      filter: {
        query: "REVISION SUMMARY"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "❄️Z-OldLabels/kdevelop-devel"
        ]
      }
    },
    {
      filter: {
        from: "noreply@phabricator.kde.org"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "❄️Z-OldLabels/kdevelop-devel"
        ]
      }
    },
    {
      filter: {
        query: "list:kdevelop.kde.org"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "❄️Z-OldLabels/kdevelop-devel"
        ]
      }
    },
    {
      filter: {
        from: "Aetf's Bot Message",
        isEscaped: true
      },
      actions: {
        markSpam: false,
        markImportant: true,
        labels: [
          "❄️Z-OldLabels/Aetf's Bot Message"
        ]
      }
    },
    {
      filter: {
        query: "CLOUDLAB.US: Profile updated from Git repository"
      },
      actions: {
        archive: true,
        markRead: true
      }
    },
    {
      filter: {
        and: [
          {
            from: "billpay@billpay.bankofamerica.com"
          },
          {
            subject: "new eBill",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        markRead: true,
        category: "updates"
      }
    },
    {
      filter: {
        subject: "\"payment is scheduled for delivery\" | \"received your payment\"",
        isEscaped: true
      },
      actions: {
        markSpam: false,
        markImportant: false,
        category: "personal"
      }
    },
    {
      filter: {
        and: [
          {
            from: "DTEEnergybill@dteenergy.com"
          },
          {
            query: "DTE Energy bill is ready to view"
          }
        ]
      },
      actions: {
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "NOREPLY@notifications.dteenergy.com"
          },
          {
            query: "dte energy payment received"
          }
        ]
      },
      actions: {
        archive: true,
        markSpam: false,
        category: "updates",
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "online.communications@alerts.comcast.net"
          },
          {
            query: "\"your bill is ready to view\""
          }
        ]
      },
      actions: {
        archive: true,
        markSpam: false,
        category: "updates",
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        query: "Michigan-BigData"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "❄️Z-OldLabels/UMich/EECS 598-009 Big Data"
        ]
      }
    },
    {
      filter: {
        query: "\"Your credit card statement is ready\" OR \"Your statement is ready for credit card\""
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "\"Your statement is available online\" OR \"You have a new statement online\""
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "\"Your Statement is Available in Mobile and Online Banking\""
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "american express \"Important Notice\" Statement"
      },
      actions: {
        archive: true,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "\"Your deposit statement is available\""
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "donotreply-comm@schwab.com"
          },
          {
            query: "Your Schwab eStatement is Ready"
          }
        ]
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "\"Your statement is now available online\" citi"
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        to: "(unlimitedcodeworks.xyz (newegg OR sameto212 OR xavih886))",
        isEscaped: true
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        markImportant: false,
        forward: "fwd@jieyou.info"
      }
    },
    {
      filter: {
        query: "\"Your statement is ready for account\""
      },
      actions: {
        archive: true,
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "-paypal -americanexpress",
            isEscaped: true
          },
          {
            query: "thank order -{recent rate survey}"
          }
        ]
      },
      actions: {
        category: "updates",
        labels: [
          "Purchase"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "pugetsoundenergy@pse.com"
          },
          {
            query: "energy bill"
          }
        ]
      },
      actions: {
        markImportant: false,
        category: "updates",
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        query: "puget sound energy \"energy bill is ready\""
      },
      actions: {
        markSpam: false,
        markImportant: false,
        category: "updates",
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "master@unlimited-code.works"
          },
          {
            query: "SMART"
          }
        ]
      },
      actions: {
        markSpam: false,
        markImportant: true,
        category: "personal",
        labels: [
          "❄️Z-OldLabels/Aetf's Bot Message"
        ]
      }
    },
    {
      filter: {
        query: "\"citizens\" access \"monthly statement\""
      },
      actions: {
        archive: true,
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "to:junk@unlimitedcodeworks.xyz OR to:junk@unlimited-code.works"
      },
      actions: {
        archive: true,
        markRead: true,
        markImportant: false,
        category: "promotions"
      }
    },
    {
      filter: {
        query: "\"sofi banking statement is available\""
      },
      actions: {
        archive: true,
        markSpam: false,
        category: "updates",
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        query: "\"Metromile monthly statement available\""
      },
      actions: {
        markSpam: false,
        category: "updates",
        labels: [
          "Auto Insurance"
        ]
      }
    },
    {
      filter: {
        query: "\"We processed your payment\""
      },
      actions: {
        archive: true,
        markRead: true,
        markImportant: false,
        category: "updates"
      }
    },
    {
      filter: {
        query: "\"renovate[bot]\""
      },
      actions: {
        archive: true,
        markRead: true,
        markImportant: false,
        category: "updates"
      }
    },
    {
      filter: {
        and: [
          {
            from: "no-reply@icbc-us.com"
          },
          {
            subject: "Statement Alert",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bank Statements"
        ]
      }
    },
    {
      filter: {
        from: "woodcreek_mgr@outlook.com"
      },
      actions: {
        labels: [
          "Housing/Woodcreek"
        ]
      }
    },
    {
      filter: {
        query: "from:TrackingUpdates@fedex.com OR from:order-update@amazon.com OR from:auto-reply@usps.com OR from:USPSInformeddelivery@email.informeddelivery.usps.com OR from:mcinfo@ups.com OR (from:help@walmart.com  AND (subject:\"Out for delivery\" OR subject:\"shipped\" OR subject:\"delivered\") )"
      },
      actions: {
        archive: true,
        markSpam: false,
        category: "updates",
        labels: [
          "❄️Z-OldLabels/Mail \u0026 Package"
        ]
      }
    },
    {
      filter: {
        subject: "\"city of bellevue\" \"invoice\"",
        isEscaped: true
      },
      actions: {
        archive: true,
        markRead: true,
        category: "updates",
        labels: [
          "Housing/Utility"
        ]
      }
    },
    {
      filter: {
        from: "noreply@republicservices.com"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "Housing/Utility"
        ]
      }
    }
  ]
}
