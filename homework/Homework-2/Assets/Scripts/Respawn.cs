using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Respawn : MonoBehaviour
{
    [SerializeField] GameObject respawnPoint;
    [SerializeField] LayerMask respawnLayer;

    void OnTriggerEnter2D(Collider2D col)
    {
        if(((1 << col.gameObject.layer) & respawnLayer.value) != 0)
        {
            transform.position = respawnPoint.transform.position;
        }
    }
}
