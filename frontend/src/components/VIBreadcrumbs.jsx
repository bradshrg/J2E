import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { TranslationContext } from './PageLayout';

const VIBreadcrumbs = ({
  currentPage = 'The Journey',
  currentPageKey,
  parentPage,
  parentPageKey,
}) => {
  const context = useContext(TranslationContext);
  const translate =
    typeof context?.t === 'function'
      ? context.t
      : (key, fallback) => fallback || key;

  const breadcrumbs = [
    {
      path: '/',
      label: translate('common.home', 'Home'),
      linkable: true,
    },
  ];

  if (parentPage?.path) {
    breadcrumbs.push({
      path: parentPage.path,
      label: translate(parentPageKey, parentPage.label || 'Section'),
      linkable: true,
    });
  }

  breadcrumbs.push({
    path: null,
    label: translate(currentPageKey, currentPage),
    linkable: false,
  });

  return (
    <nav className="breadcrumbs" aria-label="Breadcrumb">
      {breadcrumbs.map((crumb, index) => (
        <React.Fragment key={`${crumb.path || 'current'}-${index}`}>
          {index > 0 && (
            <span className="breadcrumbs__separator" aria-hidden="true">
              /
            </span>
          )}

          {crumb.linkable ? (
            <Link className="breadcrumbs__link" to={crumb.path}>
              {crumb.label}
            </Link>
          ) : (
            <span className="breadcrumbs__current" aria-current="page">
              {crumb.label}
            </span>
          )}
        </React.Fragment>
      ))}
    </nav>
  );
};

export default VIBreadcrumbs;
