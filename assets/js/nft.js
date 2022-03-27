import { $ } from './utils/dom';
import { handleError, fetchJson } from './utils/requests';

function createNFT(seed) {
  const progressText = $('.js-nft-progress');
  const statusMessage = $('.js-nft-result');

  if (!progressText || !statusMessage) return;

  progressText.classList.remove('hidden');
  statusMessage.classList.remove('hidden');

  let counter = 0;

  function proveWork(seed) {
    const buf = new ArrayBuffer(4 + 32);
    new DataView(buf).setUint32(0, seed, true);

    const randomPart = new Uint8Array(buf, 4);

    function tryNewSeed(hash) {
      if ((++counter & 0x1fff) === 0) {
        progressText.textContent = `Mining Derpthereum to mint NFT, ${counter} hashes done so far`;
      }

      // starts with at least 21 zeroes in big-endian representation
      if (new DataView(hash).getUint32(0, false) < (1 << (32 - 21))) {
        return Promise.resolve([randomPart, new Uint8Array(hash)]);
      }

      crypto.getRandomValues(randomPart);

      return crypto.subtle.digest('SHA-256', buf).then(tryNewSeed);
    }

    return crypto.subtle.digest('SHA-256', buf).then(tryNewSeed);
  }

  proveWork(seed).then(([randomPart, hash]) => {
    progressText.textContent = `Done! NFT has been created and is being verified! Your hash for it is: ${Array.from(hash).map(x => x.toString(16).padStart(2, '0')).join(' ')}`;

    fetchJson('POST', '/nft', {
      random_part: Array.from(randomPart).map(x => x.toString(16).padStart(2, '0')).join('')
    })
    .then(handleError)
    .then(() => {
      statusMessage.classList.remove('block--warning');
      statusMessage.classList.add('block--success');
      statusMessage.textContent = 'Blockchain verified your NFT, and it has been successfully created! Check your profile.'
    })
    .catch(() => {
      statusMessage.classList.remove('block--warning');
      statusMessage.classList.add('block--danger');
      statusMessage.textContent = 'Blockchain could not verify your NFT. You may already have enough of them. Check your profile.'
    });
  })
}

export function addNFTsToBooru() {
  const nftButton = $('.js-nft-button');
  const seed = $('.js-nft-seed');

  if (!nftButton || !seed) return;

  nftButton.addEventListener('click', () => {
    nftButton.classList.add('hidden');
    createNFT(parseInt(seed.textContent, 10));
  });
}
