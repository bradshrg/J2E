import React from 'react';
import { Link } from 'react-router-dom';

const pathways = [
  {
    title: 'The Journey',
    text: 'Begin with the principles, story, and practical foundation of the alkaline vegan journey.',
    to: '/TheJourney',
  },
  {
    title: 'Recipes',
    text: 'Explore focused alkaline meals, snacks, drinks, herbs, oils, seeds, and sea moss.',
    to: '/Recipes',
  },
  {
    title: 'Alkaline Shop',
    text: 'Browse sea moss, wellness products, merchandise, consultations, and related offerings.',
    to: '/MAVJStore',
  },
];

const featured = [
  {
    eyebrow: 'Nutrition',
    title: 'Alkaline Recipes',
    text: 'Simple food pathways organized around ingredients and practical preparation.',
    to: '/Recipes',
  },
  {
    eyebrow: 'Wellness',
    title: 'Vibrational Intelligence',
    text: 'Explore frequency, consciousness, biofield research, and wellness practices.',
    to: '/VibrationalIntelligence',
  },
  {
    eyebrow: 'St. Lucia',
    title: 'Journey 2 Enlightenment',
    text: 'Discover accommodations, excursions, workshops, food, agriculture, and water experiences.',
    to: '/Journey2Enlightenment',
  },
  {
    eyebrow: 'Community',
    title: 'Align With Us',
    text: 'Connect, participate, collaborate, and support the ongoing journey.',
    to: '/AlignWithUs',
  },
];

const HomePage = () => (
  <main className="new-home">
    <section className="new-home__hero">
      <div className="new-home__hero-logo">
        <img
          src="/images/MAVJLogo.jpg"
          alt="My Alkaline Vegan Journey"
          onError={(event) => {
            event.currentTarget.style.display = 'none';
          }}
        />
      </div>

      <p className="new-home__kicker">My Alkaline Vegan Journey</p>

      <h1>
        A clearer path to food, wellness, consciousness, and community.
      </h1>

      <p className="new-home__intro">
        Explore practical alkaline nutrition, plant-based recipes, sea moss,
        wellness education, and the Journey 2 Enlightenment experience in
        St. Lucia.
      </p>

      <div className="new-home__actions">
        <Link className="button button--primary" to="/TheJourney">
          Start the Journey
        </Link>
        <Link className="button button--secondary" to="/MAVJStore">
          Visit the Shop
        </Link>
      </div>
    </section>

    <section className="new-home__section">
      <div className="section-heading">
        <p>Choose your path</p>
        <h2>Explore the main areas</h2>
      </div>

      <div className="pathway-grid">
        {pathways.map((item) => (
          <Link className="pathway-card" to={item.to} key={item.to}>
            <span className="pathway-card__arrow">↗</span>
            <h3>{item.title}</h3>
            <p>{item.text}</p>
          </Link>
        ))}
      </div>
    </section>

    <section className="new-home__feature-band">
      <div>
        <p className="feature-band__eyebrow">Featured focus</p>
        <h2>Food and wellness without the visual noise</h2>
        <p>
          The homepage now introduces the major pathways instead of loading
          every video, product, gallery, announcement, game, and program into
          one very long page.
        </p>
      </div>

      <Link className="text-link" to="/MAVJSearch">
        Search the full site <span aria-hidden="true">→</span>
      </Link>
    </section>

    <section className="new-home__section">
      <div className="section-heading">
        <p>Discover more</p>
        <h2>Nutrition, wellness, and experience</h2>
      </div>

      <div className="featured-grid">
        {featured.map((item) => (
          <article className="featured-card" key={item.to}>
            <p className="featured-card__eyebrow">{item.eyebrow}</p>
            <h3>{item.title}</h3>
            <p>{item.text}</p>
            <Link to={item.to}>Learn more →</Link>
          </article>
        ))}
      </div>
    </section>

    <section className="new-home__contact">
      <div>
        <p>Questions or collaboration</p>
        <h2>Connect with My Alkaline Vegan Journey</h2>
      </div>

      <Link className="button button--primary" to="/ContactUs">
        Contact Us
      </Link>
    </section>
  </main>
);

export default HomePage;
