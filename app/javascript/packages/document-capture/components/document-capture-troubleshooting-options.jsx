import { useContext } from 'react';
import { TroubleshootingOptions } from '@18f/identity-components';
import { useI18n } from '@18f/identity-react-i18n';
import ServiceProviderContext from '../context/service-provider';
import HelpCenterContext from '../context/help-center';

/** @typedef {import('@18f/identity-components/troubleshooting-options').TroubleshootingOption} TroubleshootingOption */

/**
 * @typedef DocumentCaptureTroubleshootingOptionsProps
 *
 * @prop {string=} heading Custom heading to show in place of default.
 * @prop {string=} location Location parameter to append to links.
 */

/**
 * @param {DocumentCaptureTroubleshootingOptionsProps} props
 */
function DocumentCaptureTroubleshootingOptions({
  heading,
  location = 'document_capture_troubleshooting_options',
}) {
  const { t } = useI18n();
  const { getHelpCenterURL } = useContext(HelpCenterContext);
  const { name: spName, getFailureToProofURL } = useContext(ServiceProviderContext);

  return (
    <TroubleshootingOptions
      heading={heading}
      options={
        /** @type {TroubleshootingOption[]} */ ([
          {
            url: getHelpCenterURL({
              category: 'verify-your-identity',
              article: 'how-to-add-images-of-your-state-issued-id',
              location,
            }),
            text: t('idv.troubleshooting.options.doc_capture_tips'),
            isExternal: true,
          },
          {
            url: getHelpCenterURL({
              category: 'verify-your-identity',
              article: 'accepted-state-issued-identification',
              location,
            }),
            text: t('idv.troubleshooting.options.supported_documents'),
            isExternal: true,
          },
          spName && {
            url: getFailureToProofURL(location),
            text: t('idv.troubleshooting.options.get_help_at_sp', { sp_name: spName }),
            isExternal: true,
          },
        ].filter(Boolean))
      }
    />
  );
}

export default DocumentCaptureTroubleshootingOptions;
