import featuredImage from '../../images/The price of paralysis.jpg';
import idumotaImage from '../../images/idumota.webp';
import posterImage from '../../images/ysotposter.jpg';

export const featuredArticle = {
  slug: 'price-of-paralysis',
  title:
    'The price of paralysis: How governance failure is strangling the Nigeria promise',
  excerpt:
    '"Picture this: A nation where it takes 21 days to clear goods from ports while neighbouring Ghana manages it in 48 hours. Where N17 trillion worth of federal projects lie abandoned like graveyards of broken promises."',
  author: 'Prof. Sunday E. Atawodi',
  date: 'Jun 30, 2025',
  category: 'Governance',
  readTime: '8 min read',
  image: featuredImage,
  sections: [
    {
      heading: 'The paralysis we normalize',
      paragraphs: [
        'Nigeria loses momentum not because of a shortage of ideas, but because execution keeps stalling at the point where governance meets daily life.',
        'From port delays to abandoned public works, the cost is measured in lost competitiveness, rising consumer prices, and eroding public trust.'
      ]
    },
    {
      heading: 'Why reform feels stuck',
      paragraphs: [
        'Institutions are underpowered, incentives are misaligned, and decision cycles are too slow for a country of Nigeria&apos;s scale.',
        'A new compact is required: one that rewards implementation, protects reformers, and measures progress in months instead of decades.'
      ]
    },
    {
      heading: 'What breaks the deadlock',
      paragraphs: [
        'Start with a visible win: service delivery that people can feel within a single budget year.',
        'Then scale accountability through digital procurement, transparent project tracking, and public feedback loops.'
      ]
    }
  ]
};

export const articles = [
  featuredArticle,
  {
    slug: 'rebuild-trust-institutions',
    title: 'Policy ideas that rebuild trust in public institutions',
    excerpt:
      'What if national cohesion starts with a radically transparent civic compact? Our thinkers outline the pillars.',
    author: 'Dr. Richard Ikiebe',
    date: 'Jul 12, 2025',
    category: 'Institutions',
    readTime: '6 min read',
    image: idumotaImage,
    sections: [
      {
        heading: 'Trust is the missing infrastructure',
        paragraphs: [
          'Citizens do not reject policy; they reject opacity. Trust is built when institutions show their work and keep the public in the loop.',
          'The fastest way to rebuild credibility is to make compliance easier than evasion.'
        ]
      },
      {
        heading: 'A civic compact that is visible',
        paragraphs: [
          'Publish service charters with response times, and report monthly on performance.',
          'Create local feedback councils that turn public complaints into actionable reform tasks.'
        ]
      }
    ]
  },
  {
    slug: 'lagos-corridor-playbook',
    title: 'The governance playbook for a productive Lagos corridor',
    excerpt:
      'A field-based look at how local government reforms can unlock private investment across the Yaba axis.',
    author: 'Prof. Francis Egbokhare',
    date: 'Jul 18, 2025',
    category: 'Economy',
    readTime: '7 min read',
    image: posterImage,
    sections: [
      {
        heading: 'Why corridors matter',
        paragraphs: [
          'Economic growth is spatial. When infrastructure, zoning, and services align, investment accelerates.',
          'The Yaba corridor is a case study in how local governance can unlock a national ripple effect.'
        ]
      },
      {
        heading: 'Local reforms with national impact',
        paragraphs: [
          'Streamline permits, protect public right-of-way, and design transit priorities that serve workers.',
          'The goal is to compress decision time while expanding public participation.'
        ]
      }
    ]
  }
];
